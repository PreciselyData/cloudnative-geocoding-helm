# Configurations for Metrics, Traces and Dashboard

## Generating Insights from Metrics

The geo-addressing application microservices expose metrics which can be used for monitoring and troubleshooting the
performance and behavior of the geo-addressing application.

Depending on your alerting setup, you can set up alerts based on these metrics to proactively respond to the issues in
your application.

### Exposed Metrics

Following are the metrics exposed by Regional-Addressing Application:

> click the `▶` symbol to expand

<details>

| Metric Name                      | Type    | Description                                                                                      |
|----------------------------------|---------|--------------------------------------------------------------------------------------------------|
| executor.active                  | Counter | Number of active tasks in the executor.                                                          |
| executor.completed               | Counter | Number of completed tasks in the executor.                                                       |
| executor.pool.core               | Gauge   | Core size of the executor's thread pool.                                                         |
| executor.pool.max                | Gauge   | Maximum size of the executor's thread pool.                                                      |
| executor.pool.size               | Gauge   | Current size of the executor's thread pool.                                                      |
| executor.queue.remaining         | Gauge   | Remaining capacity of the executor's task queue.                                                  |
| executor.queued                  | Counter | Number of queued tasks in the executor.                                                          |
| http.server.requests             | Counter | Number of HTTP requests received by the server.                                                   |
| jvm.classes.loaded               | Gauge   | Number of classes loaded by the JVM.                                                             |
| jvm.classes.unloaded             | Gauge   | Number of classes unloaded by the JVM.                                                           |
| jvm.threads.daemon               | Gauge   | Number of daemon threads in the JVM.                                                             |
| jvm.threads.live                 | Gauge   | Number of live threads in the JVM.                                                               |
| jvm.threads.peak                 | Gauge   | Peak number of threads in the JVM.                                                              |
| logback.events                   | Gauge   | Number of logback events.                                                                        |
| process.cpu.usage                | Gauge   | CPU usage of the process.                                                                        |
| process.files.max                | Gauge   | Maximum number of open files allowed for the process.                                            |
| process.files.open               | Gauge   | Number of open files for the process.                                                            |
| process.start.time               | Gauge   | Start time of the process.                                                                       |
| process.uptime                   | Gauge   | Uptime of the process.                                                                           |
| system.cpu.count                 | Gauge   | Number of CPU cores in the system.                                                               |
| system.cpu.usage                 | Gauge   | Overall CPU usage of the system.                                                                 |
| system.load.average.1m           | Gauge   | Load average of the system over the last minute.                                                 |

<hr>
</details>

<br><br>
Following are the metrics exposed by country-based addressing service:

> click the `▶` symbol to expand

<details>

| Metric Name                      | Type    | Description                                                                                      |
|----------------------------------|---------|--------------------------------------------------------------------------------------------------|
| executor.active                  | Counter | Number of active tasks in the executor.                                                          |
| executor.completed               | Counter | Number of completed tasks in the executor.                                                       |
| executor.pool.core               | Gauge   | Core size of the executor's thread pool.                                                         |
| executor.pool.max                | Gauge   | Maximum size of the executor's thread pool.                                                      |
| executor.pool.size               | Gauge   | Current size of the executor's thread pool.                                                      |
| executor.queue.remaining         | Gauge   | Remaining capacity of the executor's task queue.                                                  |
| executor.queued                  | Counter | Number of queued tasks in the executor.                                                          |
| http.server.requests             | Counter | Number of HTTP requests received by the server.                                                   |
| jvm.buffer.count                 | Gauge   | Number of buffers used by the JVM.                                                               |
| jvm.buffer.memory.used           | Gauge   | Memory used by buffers in the JVM.                                                               |
| jvm.buffer.total.capacity        | Gauge   | Total capacity of buffers in the JVM.                                                            |
| jvm.classes.loaded               | Gauge   | Number of classes loaded by the JVM.                                                             |
| jvm.classes.unloaded             | Gauge   | Number of classes unloaded by the JVM.                                                           |
| jvm.gc.live.data.size            | Gauge   | Size of live data in the garbage collector.                                                      |
| jvm.gc.max.data.size             | Gauge   | Maximum size of data in the garbage collector.                                                   |
| jvm.gc.memory.allocated          | Gauge   | Memory allocated by the garbage collector.                                                       |
| jvm.gc.memory.promoted           | Gauge   | Memory promoted by the garbage collector.                                                        |
| jvm.gc.pause                     | Counter | Garbage collector pause time.                                                                    |
| jvm.memory.committed             | Gauge   | Memory committed by the JVM.                                                                    |
| jvm.memory.max                   | Gauge   | Maximum memory available to the JVM.                                                             |
| jvm.memory.used                  | Gauge   | Memory used by the JVM.                                                                         |
| jvm.threads.daemon               | Gauge   | Number of daemon threads in the JVM.                                                             |
| jvm.threads.live                 | Gauge   | Number of live threads in the JVM.                                                               |
| jvm.threads.peak                 | Gauge   | Peak number of threads in the JVM.                                                              |
| jvm.threads.states               | Gauge   | Number of threads in different states in the JVM.                                                |
| logback.events                   | Gauge   | Number of logback events.                                                                        |
| process.cpu.usage                | Gauge   | CPU usage of the process.                                                                        |
| process.files.max                | Gauge   | Maximum number of open files allowed for the process.                                            |
| process.files.open               | Gauge   | Number of open files for the process.                                                            |
| process.start.time               | Gauge   | Start time of the process.                                                                       |
| process.uptime                   | Gauge   | Uptime of the process.                                                                           |
| system.cpu.count                 | Gauge   | Number of CPU cores in the system.                                                               |
| system.cpu.usage                 | Gauge   | Overall CPU usage of the system.                                                                 |
| system.load.average.1m           | Gauge   | Load average of the system over the last minute.                                                 |

<hr>
</details>

### Configuring Metrics Monitoring

You can also set up metrics monitoring to gain insights and trigger alerts. Tools like [Prometheus](https://prometheus.io/), [Datadog](https://www.datadoghq.com/), [Dyntrace](https://www.dynatrace.com/) can be configured to analyze the metrics generated by the services within the Geo-Addressing Application. These tools are capable of providing valuable insights based on the metrics data and can be instrumental in maintaining the health and performance of your application.

This section describes how to configure Prometheus for generating insights from the metrics.

Run the below commands to install prometheus and generating insights from the metrics: (Refer to open-source [prometheus helm chart](https://github.com/prometheus-community/helm-charts))
```shell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus
```

You can then view the Prometheus-UI for visualization, run the queries and generate the alerts.

## Application Tracing
Application tracing is a technique for troubleshooting cross-application traces in more depth than a regular log.

By default, Geo-Addressing generates, collects and exports the traces
using [OpenTelemetry Instrumentation](https://opentelemetry.io/).

These traces can then be easily monitored using Microservice Trace Monitoring tools
like [Jaeger](https://www.jaegertracing.io/docs/1.49/), [Zipkin](https://zipkin.io/)
, [Datadog](https://www.datadoghq.com/).

Traces are generated for each endpoint which are: `/li/v1/oas/verify`, `/li/v1/oas/geocode`, `/li/v1/oas/autocomplete`, `/li/v1/oas/reverse-geocode`.

This section describes usage of application tracing using **_Jaeger_**. Please run the below command for installing Jaeger:
```shell
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm install jaeger jaegertracing/jaeger --set "allInOne.enabled=true" --set "query.enabled=false" --set "agent.enabled=false" --set "collector.enabled=false"
```

You can then run the Jaeger UI for visualization and viewing the traces.

## Logs and Monitoring

The Geo-Addressing Application generates logs for all its services, such as regional-addressing, country-based addressing, autocomplete, lookup, and reverse-geocode, and outputs them in JSON format to stdout.

For logs management and analysis, you have the option to configure Microservice Log Analysis tools like [Datadog](https://www.datadoghq.com/), [ELK Stack](https://www.elastic.co/elastic-stack/), [SumoLogic](https://www.sumologic.com/), [New Relic](https://newrelic.com/), and more.

Additionally, you can set up tools like [Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) or [K8s Lens](https://k8slens.dev/) for monitoring your kubernetes resources and logs easily.

These recommendations are not exhaustive, and you have the flexibility to use any Microservice Log Analysis tool that supports log scraping from stdout within your Geo-Addressing Application Deployment.

[🔗 Return to `Table of Contents` 🔗](../README.md#miscellaneous)