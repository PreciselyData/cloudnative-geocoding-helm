## FAQs

1. How can I check whether the Geo-Addressing Helm Chart is installed or not?
   <br><br>
   Once you run the helm chart command, you can monitor the helm chart creation by using the following command:
    ```shell
    kubectl get pods -n geo-addressing -w
    ```

   Please wait for all the services to be in the running stage:
   ![kubectl-all.png](../../images/kubectl-all.png)

2. How to clean up the resources if the helm-chart installation is unsuccessful?
   <br><br>
   Helm command will fail mostly because of missing mandatory parameters or not overriding few of the default
   parameters. Apart from mandatory parameters, you can always override the default values in
   the [values.yaml](../../charts/geo-addressing/values.yaml) file by using the --set parameter.

   However, you can view the logs and fix those issues by cleaning up and rerunning the helm command.
    ```shell
    kubectl describe pod [POD-NAME] -n geo-addressing
    kubectl logs [POD-NAME] -n geo-addressing
    ```

   To clean up the resources, use the following commands:
    ```shell
    helm uninstall geo-addressing -n geo-addressing
    kubectl delete job geo-addressing-data-vintage -n geo-addressing
    kubectl delete pvc addressing-hook-svc-pvc -n geo-addressing
    ```