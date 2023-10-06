import subprocess
import json
import time
import os
import argparse

parser = argparse.ArgumentParser(description='Creates EFS and enables it to be accessed from cluster')
parser.add_argument('--cluster-name', dest='cluster_name',
                    help='Cluster name should be provided for enabling the EFS to be accessed from cluster.',
                    required=True)
parser.add_argument('--efs-name', dest='efs_name',
                    help='Name of the EFS to be created.',
                    default="precisely-geo-addressing-efs",
                    metavar="precisely-geo-addressing-efs",
                    required=False)
parser.add_argument('--security-group-name', dest='sg_name',
                    help='Name of the Security Group to be created.',
                    default="precisely-geo-addressing-sg",
                    metavar="precisely-geo-addressing-sg",
                    required=False)
parser.add_argument('--existing', dest='existing',
                    default=False,
                    help='Flag to indicate whether to link existing EFS',
                    required=False, type=bool)
parser.add_argument('--aws-region', dest='aws_region',
                    default='us-east-1',
                    help='AWS Account Region',
                    required=False)
parser.add_argument('--aws-access-key', dest='aws_access_key',
                    help='AWS Account access key',
                    required=False)
parser.add_argument('--aws-secret-key', dest='aws_secret_key',
                    help='AWS Account secret key',
                    required=False)
parser.add_argument('--file-system-id', dest='file_system_id',
                    help='File system id to be linked to EKS cluster',
                    metavar="fs-asdf324sfddf3112")

args = parser.parse_args()

CLUSTER_NAME = args.cluster_name
EXISTING = args.existing
AWS_REGION = args.aws_region
AWS_ACCESS_KEY = args.aws_access_key
AWS_SECRET_KEY = args.aws_secret_key
EFS_NAME = args.efs_name
EFS_ID = args.file_system_id
SG_NAME = args.sg_name

try:
    if not AWS_REGION:
        AWS_REGION = "us-east-1"
    os.environ.update({"AWS_DEFAULT_REGION": str(AWS_REGION)})
    if AWS_ACCESS_KEY:
        os.environ.update({"AWS_ACCESS_KEY_ID": str(AWS_ACCESS_KEY)})
    if AWS_SECRET_KEY:
        os.environ.update({"AWS_SECRET_ACCESS_KEY": str(AWS_SECRET_KEY)})

    subprocess.check_output('aws configure set output json', shell=True)

    vpc_id = subprocess.check_output(
        f'aws eks describe-cluster --name {CLUSTER_NAME} --query "cluster.resourcesVpcConfig.vpcId" --output text'
        f' --region {AWS_REGION}',
        shell=True, stderr=subprocess.STDOUT, encoding="utf-8").strip('\n')

    cidr = subprocess.check_output(
        f'aws ec2 describe-vpcs --vpc-ids {vpc_id} --query "Vpcs[].CidrBlock" --output text '
        f'--region {AWS_REGION}',
        shell=True, stderr=subprocess.STDOUT, encoding="utf-8").strip('\n')

    if EXISTING:
        if not EFS_ID:
            raise Exception("--file-system-id is a mandatory parameter while linking to existing EFS to EKS.")
        try:
            result = subprocess.check_output(
                f' aws efs describe-file-systems --file-system-id {EFS_ID} --output json',
                shell=True, stderr=subprocess.STDOUT, encoding="utf-8")
            output = json.loads(result)
            filesystem_id = output["FileSystems"][0]["FileSystemId"]
        except subprocess.CalledProcessError as ex:
            print(f"EFS with file-system-id {EFS_ID} not found")
            print(f"Exception: {ex}, Output: {ex.output}, StdOut: {ex.stdout}, StdErr: {ex.stderr}")
            raise Exception(ex.output)

    else:
        result = subprocess.check_output(
            f'aws efs create-file-system --throughput-mode elastic '
            f'--tags "Key=Name,Value={EFS_NAME}" --creation-token {EFS_NAME} --region {AWS_REGION}',
            shell=True, stderr=subprocess.STDOUT, encoding="utf-8")
        output = json.loads(result)
        filesystem_id = output["FileSystemId"]
        print(f"Created FileSystem with FileSystemId: {filesystem_id}")
        availability = subprocess.check_output(
            f'aws efs describe-file-systems --file-system-id {filesystem_id} '
            f'--query "FileSystems[0].LifeCycleState" --output text --region {AWS_REGION}',
            shell=True, stderr=subprocess.STDOUT, encoding="utf-8").strip('\n')
        print("Waiting for fileSystem LifeCycleState to be available...")
        while availability != "available":
            time.sleep(3)
            availability = subprocess.check_output(
                f'aws efs describe-file-systems --file-system-id {filesystem_id} '
                f'--query "FileSystems[0].LifeCycleState" --output text --region {AWS_REGION}',
                shell=True, stderr=subprocess.STDOUT, encoding="utf-8").strip('\n')

    group_json = subprocess.check_output(
        f'aws ec2 create-security-group --description "To access EFS in EKS"  --vpc-id {vpc_id} '
        f'--group-name {SG_NAME} --region {AWS_REGION}',
        shell=True, stderr=subprocess.STDOUT, encoding="utf-8")
    output = json.loads(group_json)
    sg_id = output["GroupId"]

    subprocess.check_output(
        f'aws ec2 authorize-security-group-ingress --group-id {sg_id} --cidr {cidr} --protocol tcp --port 2049 '
        f'--region {AWS_REGION}',
        shell=True, stderr=subprocess.STDOUT, encoding="utf-8")

    subnets_str = subprocess.check_output(
        f'aws eks describe-cluster --name {CLUSTER_NAME} --query "cluster.resourcesVpcConfig.subnetIds"'
        f' --region {AWS_REGION}',
        shell=True, stderr=subprocess.STDOUT, encoding="utf-8")
    subnets = json.loads(subnets_str)

    print(f"SubnetIDs: {subnets}")
    for subnet in subnets:
        print(f"Mounting target for subnetId: {subnet}")
        subprocess.check_output(
            f'aws efs create-mount-target --file-system-id {filesystem_id} --subnet-id {subnet} --security-groups {sg_id}'
            f' --region {AWS_REGION}',
            shell=True, stderr=subprocess.STDOUT, encoding="utf-8")
except subprocess.CalledProcessError as ex:
    print(f"Exception: {ex}, Output: {ex.output}, StdOut: {ex.stdout}, StdErr: {ex.stderr}")
    raise Exception(ex.output)
