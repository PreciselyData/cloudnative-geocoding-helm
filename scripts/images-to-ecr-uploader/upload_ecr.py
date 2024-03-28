import argparse
import re
import os
import base64
import json
import time
import requests
import urllib
import os.path
from builtins import bytes
from zipfile import ZipFile
import subprocess


def current_milli_time(): return int(round(time.time() * 1000))


GEOCODING_DOCKER_PRODUCT = "GEO ADDRESSING DOCKER IMAGE#GLOBAL#ALL GLB#Spectrum Platform Data"


class DataDeliveryClient:
    auth_token = ''
    token_expiration = 0

    __api_host = 'https://api.precisely.com'

    api_url = __api_host + '/digitalDeliveryServices/v1/'
    auth_url = __api_host + '/oauth/token'
    pdx_api_url = __api_host + '/pdx/api/public/sdk/v1/'

    @property
    def api_host(self):
        return self.__api_host

    @api_host.setter
    def api_host(self, var):
        self.__api_host = 'https://' + var
        self.api_url = self.api_host + '/digitalDeliveryServices/v1/'
        self.auth_url = self.api_host + '/oauth/token'
        self.pdx_api_url = self.api_host + '/pdx/api/public/sdk/v1/'

    def __init__(self, api_key, shared_secret, app_id):
        self.api_key = api_key
        self.shared_secret = shared_secret
        self.app_id = app_id

    def get_deliveries(self, product_name, geography=None, roster_granularity=None, page_number=1, limit=None,
                       min_release_date=None, data_format=None, preferred_format: bool = False,
                       latest: bool = False):
        params = {}
        if latest:
            params['byLatest'] = True
        if product_name:
            params['ProductName'] = product_name
        if geography:
            params['geography'] = geography
        if roster_granularity:
            params['rosterGranularity'] = roster_granularity
        if page_number:
            params['pageNumber'] = int(page_number)
        if limit:
            params['pageSize'] = int(limit)
        if min_release_date:
            params['laterThanDate'] = min_release_date
        if data_format:
            params['dataFormat'] = data_format
        if preferred_format:
            params['preference'] = 'true'

        try:
            response = self.get(url=self.pdx_api_url + 'data-deliveries', params=params,
                                headers=self.create_headers())
            return json.loads(response.text)
        except Exception as exception:
            return exception

    def create_headers(self):
        return {
            'Authorization': 'Bearer ' + self.get_auth_token()
        }

    def get_auth_token(self):
        if not self.auth_token or current_milli_time() > self.token_expiration:
            self.get_new_auth_token()

        return self.auth_token

    def get_new_auth_token(self):

        params = {
            'grant_type': 'client_credentials'
        }

        headers = {
            'Authorization': 'Basic ' + base64.b64encode(
                bytes(self.api_key + ':' + self.shared_secret, 'utf-8')).decode('utf-8')
        }

        response = self.post(self.auth_url, headers, data=params)
        # print('Proxy server invoked')
        response_json = json.loads(response.text)

        if 'access_token' in response_json:
            self.auth_token = response_json['access_token']
            self.token_expiration = current_milli_time(
            ) + (int(response_json['expiresIn']) * 1000)
        else:
            raise Exception(
                'An error occurred getting authorization info, please check your api key and shared secret.')

    def post(self, url, headers=None, data=None):
        if headers is None:
            headers = {}
        if self.app_id:
            headers['x-pb-appid'] = self.app_id
            response = requests.post(url=url, data=data, headers=headers)
        return response

    def get(self, url, headers=None, params=None):
        if headers is None:
            headers = {}
        if self.app_id:
            headers['x-pb-appid'] = self.app_id
            response = requests.get(
                url, stream=True, headers=headers, params=params)
        return response


def unzip(path, zip_filename):
    with ZipFile(zip_filename, 'r') as handle:
        print("Extracting {:s} to {:s}".format(zip_filename, path))
        handle.extractall(path=path)


def get_argument_parser():
    parser = argparse.ArgumentParser(description='Interacts with the Digital Data Delivery API.')
    parser.add_argument('--pdx-api-key', dest='pdx_api_key',
                        help='The API key provided by the Software and Data Marketplace portal.',
                        required=False)
    parser.add_argument('--pdx-api-secret', dest='pdx_api_secret',
                        help='The shared secret provided by the Software and Data Marketplace portal.',
                        required=False)
    parser.add_argument('--local-path', dest='local_path',
                        help='The base path for downloading and extracting product locally.',
                        required=False)
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
    return parser.parse_args()


def get_product(product_name):
    pieces = product_name.split('#')
    product_name = pieces[0]
    geography = pieces[1]
    roster_gran = pieces[2]
    data_format = pieces[3]
    try:
        search_results = client.get_deliveries(product_name, geography, roster_gran, 1, None, None, data_format,
                                                latest=True)
        if 'errors' in search_results:
            raise Exception(f'An error occurred getting product information: {search_results}')

        try:
            if dict(search_results).get('deliveries', None) is None:
                raise Exception(f'Deliveries are not available for the product: {product_name}'
                                f'. Response from PDX: {search_results}')
            for delivery_info in search_results['deliveries']:
                return (product_name, delivery_info['downloadUrl'])
        except Exception as exp:
            raise exp

    except Exception as exp:
        raise exp
    return (None, None)


def download_spd_to_local(product_url, spd_base_path):
    download_file_name = re.sub(r'.*/(.+)\?.*', r'\1', product_url)
    file_path = os.path.join(spd_base_path, download_file_name)
    print('Downloading {:s} to {:s}'.format(download_file_name, file_path))
    urllib.request.urlretrieve(product_url, file_path)
    return file_path


args = get_argument_parser()

PDX_API_KEY = args.pdx_api_key
PDX_SECRET = args.pdx_api_secret
LOCAL_PATH = args.local_path
AWS_REGION = args.aws_region
AWS_ACCESS_KEY = args.aws_access_key
AWS_SECRET_KEY = args.aws_secret_key
image_tag = '1.0.0'
date_folder = str(time.strftime("%Y%m%d%H%M"))

if not AWS_REGION:
    AWS_REGION = "us-east-1"

os.environ.update({"AWS_DEFAULT_REGION": str(AWS_REGION)})

if AWS_ACCESS_KEY:
    os.environ.update({"AWS_ACCESS_KEY_ID": str(AWS_ACCESS_KEY)})
if AWS_SECRET_KEY:
    os.environ.update({"AWS_SECRET_ACCESS_KEY": str(AWS_SECRET_KEY)})

if not LOCAL_PATH:
    LOCAL_PATH = os.getcwd()

client = DataDeliveryClient(PDX_API_KEY, PDX_SECRET, "SDM_HELM_APP_1.0.0")
spd_path = os.path.join(LOCAL_PATH, "docker_images")
os.makedirs(spd_path, exist_ok=True)

try:
    product_name, product_url = get_product(GEOCODING_DOCKER_PRODUCT)
    if not product_name and not product_url:
        raise Exception(
            f"No Deliveries available for product {GEOCODING_DOCKER_PRODUCT}. "
            "To request access to the particular data, please visit https://data.precisely.com/")
except Exception as ex:
    raise Exception(f'Exception while getting download url for {GEOCODING_DOCKER_PRODUCT}: {ex}', ex)

try:
    file_path = download_spd_to_local(product_url, spd_path)
    if file_path and os.path.exists(file_path):
        unzip(spd_path, file_path)
except Exception as ex:
    raise Exception(f'Exception while downloading spds to local for {GEOCODING_DOCKER_PRODUCT}: {ex}', ex)

try:
    sts_identity_str = subprocess.check_output(
        f'aws sts get-caller-identity',
        shell=True, stderr=subprocess.STDOUT, encoding="utf-8")
    sts_identity = json.loads(sts_identity_str)

    account_id = sts_identity["Account"]

    ecr_url = f'{account_id}.dkr.ecr.{AWS_REGION}.amazonaws.com'
    subprocess.check_output(f'aws ecr get-login-password --region {AWS_REGION} | docker login --username AWS --password-stdin {ecr_url}', shell=True)

    images = dict()
    for file_path in os.listdir(spd_path):
        os.chdir(spd_path)
        if file_path.endswith('.tar'):
            try:
                print(f'Loading {file_path} into docker')
                print(subprocess.check_output(
                    f'docker load -i {file_path}',
                    shell=True, stderr=subprocess.STDOUT, encoding="utf-8"))

                file_name = os.path.basename(file_path)
                file_name_withour_ext = os.path.basename(file_path).split(".")[0]
                createRepo = True
                
                try:
                    subprocess.check_output(
                    f'aws ecr describe-repositories --repository-names {file_name_withour_ext}',
                    shell=True, stderr=subprocess.STDOUT, encoding="utf-8")
                    createRepo = False
                    print(f'Repository {ecr_url}/{file_name_withour_ext} already exist. Skipping creation!')
                except:
                    createRepo = True

                if createRepo:
                    print(f'Repository {ecr_url}/{file_name_withour_ext} does not already exist. Creating!')
                    print(subprocess.check_output(
                    f'aws ecr create-repository --repository-name {file_name_withour_ext}',
                    shell=True, stderr=subprocess.STDOUT, encoding="utf-8"))

                print(subprocess.check_output(
                    f'docker tag {file_name_withour_ext}:latest {ecr_url}/{file_name_withour_ext}:{image_tag}',
                    shell=True, stderr=subprocess.STDOUT, encoding="utf-8"))
                
                print(subprocess.check_output(
                    f'docker push {ecr_url}/{file_name_withour_ext}:{image_tag}',
                    shell=True, stderr=subprocess.STDOUT, encoding="utf-8"))
                images[file_name_withour_ext] = f'{ecr_url}/{file_name_withour_ext}:{image_tag}'

            except Exception as ex:
                print(f"Exception: {ex}, Output: {ex.output}, StdOut: {ex.stdout}, StdErr: {ex.stderr}")
    
    if len(images) != 0:
        print(f"Precisely geocoding docker images successfully pushed into {ecr_url}")
        print(json.dumps(images, indent=4))
    else:
        print(f"Failed to push Precisely geocoding docker images into {ecr_url}")

except Exception as ex:
    print(f"Exception: {ex}, Output: {ex.output}, StdOut: {ex.stdout}, StdErr: {ex.stderr}")

try:
    import shutil
    os.chdir(f'..')
    print(f'Deleting local directory: {spd_path}')
    shutil.rmtree(spd_path, ignore_errors=True)
except Exception as e:
    print(
        f"Unable to delete {spd_path} -> Exception: {e}")

