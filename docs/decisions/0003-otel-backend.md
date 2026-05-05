# OpenTelemetry backend

## Context and Problem Statement

We need to store and visualize OpenTelemetry signals. Stack requirements:

- open-source, self-hosted, free for commercial use,
- easy to deploy and maintain,
- low resource consumption: CPU, memory, storage,
- single dashboard to display all signals,
- single query language,
- features: logs storage, metrics storage, traces storage, visualization, alerts, configuration as code, OAuth2 support.

## Considered Options

### LGTM stack: Loki, Grafana, Tempo, Mimir

docs:

- [grafana](https://grafana.com/oss/grafana/)
  - [helm chart](https://grafana.com/docs/grafana/latest/setup-grafana/installation/helm/)
  - [config](https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/)
  - [oauth](https://grafana.com/docs/grafana/latest/setup-grafana/configure-access/configure-authentication/google/)
  - [terraform provider](https://registry.terraform.io/providers/grafana/grafana/latest)
- [loki](https://grafana.com/oss/loki/)
  - [helm chart](https://grafana.com/docs/loki/latest/setup/install/helm/)
  - [config](https://grafana.com/docs/loki/latest/configure/)
  - [gcs](https://grafana.com/docs/loki/latest/configure/storage/#gcp-deployment-gcs-single-store), [more gcs](https://grafana.com/docs/loki/latest/setup/install/helm/configure-storage/)
  - [otel](https://grafana.com/docs/loki/latest/send-data/otel/#configure-the-opentelemetry-collector-to-write-logs-into-loki)
- [mimir](https://grafana.com/oss/mimir/)
  - [helm chart](https://grafana.com/docs/mimir/latest/set-up/helm-chart/), [more helm](https://grafana.com/docs/helm-charts/tempo-distributed/next/get-started-helm-charts/)
  - [config](https://grafana.com/docs/mimir/latest/configure/configuration-parameters/)
  - [gcs](https://grafana.com/docs/mimir/latest/configure/configure-object-storage-backend/#gcs)
  - [otel](https://grafana.com/docs/mimir/latest/configure/configure-otel-collector/#use-the-opentelemetry-protocol)
- [tempo](https://grafana.com/oss/tempo/)
  - [helm chart](https://grafana.com/docs/tempo/latest/set-up-for-tracing/setup-tempo/deploy/kubernetes/helm-chart/)
  - [config](https://grafana.com/docs/tempo/latest/configuration/manifest/)
  - [gcs](https://grafana.com/docs/tempo/latest/configuration/hosted-storage/gcs/)
- [otel](https://grafana.com/oss/opentelemetry/)

pros:

- well-known industry standard
- docs are fine
- components have clear responsibility separation
- good OpenTelemetry and Prometheus support

cons:

- very complex setup and poor Helm charts quality (very poor!)
- version compatibility burden (hope-it-will-work driven development)
- a lot of services to manage
- 3 different query languages: LogQL, PromQL, TraceQL
- [bad performance of Loki full-text search](https://signoz.io/blog/logs-performance-benchmark/)

```
$ kubectl get pod --all-namespaces
NAMESPACE                        NAME                                                       READY   STATUS      RESTARTS       AGE
o11y-grafana                     grafana-9f94bf475-mgwnm                                    1/1     Running     0              7m35s
o11y-grafana                     postgresql-0                                               1/1     Running     0              8m
o11y-loki                        loki-backend-0                                             2/2     Running     0              40m
o11y-loki                        loki-canary-mdhtt                                          1/1     Running     0              40m
o11y-loki                        loki-canary-nt28z                                          1/1     Running     0              40m
o11y-loki                        loki-canary-xqjhk                                          1/1     Running     0              40m
o11y-loki                        loki-chunks-cache-0                                        2/2     Running     0              40m
o11y-loki                        loki-gateway-66d996559-s6vl2                               1/1     Running     0              40m
o11y-loki                        loki-read-7599bf4f47-qlbff                                 1/1     Running     0              40m
o11y-loki                        loki-results-cache-0                                       2/2     Running     0              40m
o11y-loki                        loki-write-0                                               1/1     Running     0              40m
o11y-mimir                       mimir-compactor-0                                          1/1     Running     0              39m
o11y-mimir                       mimir-distributor-69456b5684-rzsp9                         1/1     Running     0              39m
o11y-mimir                       mimir-ingester-0                                           1/1     Running     0              39m
o11y-mimir                       mimir-nginx-85b87885c7-x9x8x                               1/1     Running     0              39m
o11y-mimir                       mimir-overrides-exporter-69c5b4c87c-4vhv4                  1/1     Running     0              39m
o11y-mimir                       mimir-querier-7d49f57c59-b9sz9                             1/1     Running     0              39m
o11y-mimir                       mimir-query-frontend-5589f6f695-cxkdr                      1/1     Running     0              39m
o11y-mimir                       mimir-query-scheduler-b54c64fc7-8k6rc                      1/1     Running     0              39m
o11y-mimir                       mimir-rollout-operator-56d57dcbfc-fqqwn                    1/1     Running     0              39m
o11y-mimir                       mimir-ruler-64dbcf5cb7-hrg44                               1/1     Running     0              39m
o11y-mimir                       mimir-store-gateway-0                                      1/1     Running     0              39m
o11y-tempo                       tempo-compactor-67d7ffd6d4-j7kpb                           1/1     Running     2 (39m ago)    39m
o11y-tempo                       tempo-distributor-54b9466f-cqppk                           1/1     Running     2 (39m ago)    39m
o11y-tempo                       tempo-gateway-59d88db97c-thhng                             1/1     Running     0              39m
o11y-tempo                       tempo-ingester-0                                           1/1     Running     1 (39m ago)    39m
o11y-tempo                       tempo-memcached-0                                          1/1     Running     0              39m
o11y-tempo                       tempo-querier-c965c47cd-nmgh7                              1/1     Running     2 (39m ago)    39m
o11y-tempo                       tempo-query-frontend-5b84c86f96-552n4                      1/1     Running     1 (39m ago)    39m

$ kubectl top pod --all-namespaces
NAMESPACE                        NAME                                                       CPU(cores)   MEMORY(bytes)
o11y-grafana                     grafana-9f94bf475-mgwnm                                    17m          124Mi
o11y-grafana                     postgresql-0                                               17m          51Mi
o11y-loki                        loki-backend-0                                             7m           139Mi
o11y-loki                        loki-canary-mdhtt                                          2m           16Mi
o11y-loki                        loki-canary-nt28z                                          2m           16Mi
o11y-loki                        loki-canary-xqjhk                                          2m           13Mi
o11y-loki                        loki-chunks-cache-0                                        1m           3Mi
o11y-loki                        loki-gateway-66d996559-s6vl2                               4m           11Mi
o11y-loki                        loki-read-7599bf4f47-qlbff                                 15m          73Mi
o11y-loki                        loki-results-cache-0                                       1m           6Mi
o11y-loki                        loki-write-0                                               15m          80Mi
o11y-mimir                       mimir-compactor-0                                          5m           21Mi
o11y-mimir                       mimir-distributor-69456b5684-rzsp9                         5m           26Mi
o11y-mimir                       mimir-ingester-0                                           6m           23Mi
o11y-mimir                       mimir-nginx-85b87885c7-x9x8x                               1m           11Mi
o11y-mimir                       mimir-overrides-exporter-69c5b4c87c-4vhv4                  3m           16Mi
o11y-mimir                       mimir-querier-7d49f57c59-b9sz9                             6m           30Mi
o11y-mimir                       mimir-query-frontend-5589f6f695-cxkdr                      6m           21Mi
o11y-mimir                       mimir-query-scheduler-b54c64fc7-8k6rc                      4m           16Mi
o11y-mimir                       mimir-rollout-operator-56d57dcbfc-fqqwn                    1m           9Mi
o11y-mimir                       mimir-ruler-64dbcf5cb7-hrg44                               6m           29Mi
o11y-mimir                       mimir-store-gateway-0                                      74m          24Mi
o11y-tempo                       tempo-compactor-67d7ffd6d4-j7kpb                           2m           26Mi
o11y-tempo                       tempo-distributor-54b9466f-cqppk                           2m           25Mi
o11y-tempo                       tempo-gateway-59d88db97c-thhng                             1m           11Mi
o11y-tempo                       tempo-ingester-0                                           2m           25Mi
o11y-tempo                       tempo-memcached-0                                          1m           1Mi
o11y-tempo                       tempo-querier-c965c47cd-nmgh7                              2m           28Mi
o11y-tempo                       tempo-query-frontend-5b84c86f96-552n4                      1m           22Mi
```

### Elastic stack: Elasticsearch, Kibana, APM Server + Elastic Cloud on Kubernetes (ECK)

docs:

- [eck](https://www.elastic.co/elastic-cloud-kubernetes)
- elasticsearch
  - [crd](https://www.elastic.co/guide/en/cloud-on-k8s/2.16/k8s-api-elasticsearch-k8s-elastic-co-v1.html)
- kibana
  - [crd](https://www.elastic.co/guide/en/cloud-on-k8s/2.16/k8s-api-kibana-k8s-elastic-co-v1.html)
- apm server
  - [crd](https://www.elastic.co/guide/en/cloud-on-k8s/2.16/k8s-api-apm-k8s-elastic-co-v1.html)
  - [config](https://www.elastic.co/docs/solutions/observability/apm/apm-server/configure)
  - [otel](https://www.elastic.co/docs/solutions/observability/apm/opentelemetry/upstream-opentelemetry-collectors-language-sdks)
- [otel](https://www.elastic.co/what-is/opentelemetry)
- [terraform provider](https://registry.terraform.io/providers/elastic/elasticstack/latest)

pros:

- top quality docs, but amount of them is overwhelming
- top quality Kubernetes operator - it's a pleasure to deploy this stack
- one version for all components - no version compatibility burden
- one storage driver, one data format to work with, one scaling mechanism - it's just possible to learn and master this tool; this knowledge is also usable in another places, not just for observability - it's good to know Elasticsearch
- best full-text search support for logs

cons:

- JVM... consumes a lot of memory
- [elasticsearch is not designed as a analytical database](https://signoz.io/blog/logs-performance-benchmark/)

```
$ kubectl get pod --all-namespaces
NAMESPACE                        NAME                                                       READY   STATUS      RESTARTS       AGE
o11y-apm-server                  apm-server-apm-server-586ddbff46-9f2nb                     1/1     Running     0              40m
o11y-elasticsearch               elasticsearch-es-default-0                                 1/1     Running     0              40m
o11y-kibana                      kibana-kb-5d544544f7-vs65t                                 1/1     Running     0              40m

$ kubectl top pod --all-namespaces
NAMESPACE                        NAME                                                       CPU(cores)   MEMORY(bytes)
o11y-apm-server                  apm-server-apm-server-586ddbff46-9f2nb                     1m           10Mi
o11y-elasticsearch               elasticsearch-es-default-0                                 29m          2602Mi
o11y-kibana                      kibana-kb-5d544544f7-vs65t                                 25m          616Mi
```

### SigNoz

docs:

- [signoz](https://signoz.io/)
  - [source code](https://github.com/SigNoz/signoz)
  - [helm chart](https://github.com/SigNoz/charts/tree/main/charts/signoz)
  - [terraform provider](https://registry.terraform.io/providers/SigNoz/signoz/latest), [source code](https://github.com/SigNoz/terraform-provider-signoz)
  - [gcp deployment](https://signoz.io/docs/install/kubernetes/gcp/)
  - [otel config](https://signoz.io/docs/opentelemetry-collection-agents/opentelemetry-collector/configuration/)
  - [awesome otel](https://github.com/SigNoz/Awesome-OpenTelemetry)
- [external clickhouse](https://signoz.io/docs/operate/clickhouse/external-clickhouse/)
  - [clickhouse](https://clickhouse.com/)
  - [source code](https://github.com/ClickHouse/ClickHouse)
  - helm chart [by signoz](https://github.com/SigNoz/charts/tree/main/charts/clickhouse), [by bitnami](https://github.com/bitnami/charts/tree/main/bitnami/clickhouse)
- https://clickhouse.com/blog/signoz-observability-solution-with-clickhouse-and-open-telemetry

pros:

- pretty simple setup: SigNoz, ClickHouse, ZooKeeper
- easy deployment - works out-of-the-box

cons:

- it would be better to not maintain ZooKeeper, but probably will be replaced with ClickHouse Keeper
  - https://github.com/SigNoz/signoz/issues/7002
  - https://github.com/SigNoz/charts/issues/610

```
$ kubectl get pod --all-namespaces
NAMESPACE                        NAME                                                       READY   STATUS      RESTARTS       AGE
o11y-signoz                      chi-signoz-clickhouse-cluster-0-0-0                        1/1     Running     0              26m
o11y-signoz                      signoz-0                                                   1/1     Running     0              26m
o11y-signoz                      signoz-clickhouse-operator-7df8948f8c-jj2vk                2/2     Running     2 (26m ago)    26m
o11y-signoz                      signoz-otel-collector-66d94cf979-ncvlx                     1/1     Running     0              26m
o11y-signoz                      signoz-schema-migrator-async-init-6dxjc                    0/1     Completed   0              26m
o11y-signoz                      signoz-schema-migrator-sync-init-dbdc7                     0/1     Completed   0              26m
o11y-signoz                      signoz-zookeeper-0                                         1/1     Running     0              26m

$ kubectl top pod --all-namespaces
NAMESPACE                        NAME                                                       CPU(cores)   MEMORY(bytes)
o11y-signoz                      chi-signoz-clickhouse-cluster-0-0-0                        93m          548Mi
o11y-signoz                      signoz-0                                                   2m           134Mi
o11y-signoz                      signoz-clickhouse-operator-7df8948f8c-jj2vk                1m           22Mi
o11y-signoz                      signoz-otel-collector-66d94cf979-ncvlx                     2m           45Mi
o11y-signoz                      signoz-zookeeper-0                                         7m           757Mi
```

### ClickStack: ClickHouse, HyperDX

docs:

- [clickstack](https://clickhouse.com/use-cases/observability)
  - [docs](https://clickhouse.com/docs/use-cases/observability/clickstack)
  - [tables and schemas](https://clickhouse.com/docs/use-cases/observability/clickstack/ingesting-data/schemas)
  - [dashboards](https://clickhouse.com/docs/use-cases/observability/clickstack/dashboards#presets)
- [clickhouse](https://clickhouse.com/)
  - [repo](https://github.com/ClickHouse/ClickHouse)
- [hyperdx](https://www.hyperdx.io/)
  - [repo](https://github.com/hyperdxio/hyperdx)
  - [charts](https://github.com/hyperdxio/helm-charts)
- deploy
  - [helm](https://clickhouse.com/docs/use-cases/observability/clickstack/deployment/helm)
  - [gcp](https://clickhouse.com/docs/use-cases/observability/clickstack/deployment/helm-cloud#google-kubernetes-engine-gke)
  - [config](https://clickhouse.com/docs/use-cases/observability/clickstack/config#helm)
- config
  - [otel k8s](https://opentelemetry.io/docs/platforms/kubernetes/collector/components/)
  - [otel chart](https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-collector)
  - [hyperdx k8s](https://www.hyperdx.io/docs/install/kubernetes)
- demo
  - [docs](https://clickhouse.com/docs/use-cases/observability/clickstack/getting-started/remote-demo-data#otel-demo)
  - [repo](https://github.com/ClickHouse/opentelemetry-demo), [forked from](https://github.com/open-telemetry/opentelemetry-demo)

pros:

- pretty simple setup: HyperDX, MongoDB, ClickHouse
- easy deployment - works out-of-the-box

cons:

- cannot manage "Ingestion API Key" as code

```
$ kubectl get pod --all-namespaces
NAMESPACE                        NAME                                                       READY   STATUS                   RESTARTS      AGE
o11y-clickstack                  clickstack-app-7c5c97f665-4ktf5                            1/1     Running                  0             118s
o11y-clickstack                  clickstack-clickhouse-b48668b89-8lwn7                      1/1     Running                  0             118s
o11y-clickstack                  clickstack-mongodb-7957dc8685-sjv7q                        1/1     Running                  0             118s
o11y-clickstack                  clickstack-otel-collector-6b47bdc857-fxzbj                 1/1     Running                  0             118s

$ kubectl top pod --all-namespaces
NAMESPACE                        NAME                                                       CPU(cores)   MEMORY(bytes)
o11y-clickstack                  clickstack-app-7c5c97f665-4ktf5                            120m         432Mi
o11y-clickstack                  clickstack-clickhouse-b48668b89-8lwn7                      63m          220Mi
o11y-clickstack                  clickstack-mongodb-7957dc8685-sjv7q                        9m           66Mi
o11y-clickstack                  clickstack-otel-collector-6b47bdc857-fxzbj                 37m          50Mi
```

### Custom stack: Grafana, ClickHouse

links:

- [grafana](https://grafana.com/oss/grafana/)
  - [source code](https://github.com/grafana/grafana)
  - [docker image](https://hub.docker.com/r/grafana/grafana)
    - [docs](https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/)
  - kubernetes
    - [docs](https://grafana.com/docs/grafana/latest/setup-grafana/installation/kubernetes/)
  - [helm chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana)
    - [docs](https://grafana.com/docs/grafana/latest/setup-grafana/installation/helm/)
  - [tf provider](https://registry.terraform.io/providers/grafana/grafana/latest)
    - [source code](https://github.com/grafana/terraform-provider-grafana)
  - [cli app](https://grafana.github.io/grafanactl/)
    - [source code](https://github.com/grafana/grafanactl)
  - [config provisioning](https://grafana.com/docs/grafana/latest/administration/provisioning/), [alerts provisioning](https://grafana.com/docs/grafana/latest/alerting/set-up/provision-alerting-resources/)
- [postgres](https://www.postgresql.org/)
  - [source code](https://github.com/postgres/postgres)
  - [docker official image](https://hub.docker.com/_/postgres)
  - [grafana database config](https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#database)
- [clickhouse](https://clickhouse.com/clickhouse)
  - [source code](https://github.com/ClickHouse/ClickHouse)
  - [docker image](https://hub.docker.com/r/clickhouse/clickhouse-server/), [docker official image](https://hub.docker.com/_/clickhouse)
    - [docs](https://clickhouse.com/docs/install/docker)
  - kubernetes deployment
    - [chart by HyperDX (ClickStack)](https://github.com/hyperdxio/helm-charts/tree/main/charts/clickstack)
    - [chart by SigNoz](https://github.com/SigNoz/charts/tree/main/charts/clickhouse)
    - [chart by korax-dev](https://github.com/korax-dev/clickhouse-k8s/tree/main/charts/clickhouse)
    - [chart by Altinity](https://github.com/Altinity/helm-charts/tree/main/charts/clickhouse)
    - [operator by Altinity](https://github.com/Altinity/clickhouse-operator)
  - otel exporter
    - [source code](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/clickhouseexporter)
  - [grafana datasource plugin](https://grafana.com/grafana/plugins/grafana-clickhouse-datasource/)
    - [source code](https://github.com/grafana/clickhouse-datasource)
    - another [plugin by Altinity](https://grafana.com/grafana/plugins/vertamedia-clickhouse-datasource/)
- [clickhouse keeper](https://clickhouse.com/clickhouse/keeper)
  - [scaling video](https://www.youtube.com/watch?v=vBjCJtw_Ei0)
- https://clickhouse.com/docs/observability/grafana
- https://clickhouse.com/docs/integrations/grafana
- https://clickhouse.com/docs/integrations/grafana/config

pros:

- well-known and extensible dashboards
- blazing-fast storage
- one query language (SQL)
- architecture can't be simpler: OpenTelemetry collectors writes signals to ClickHouse database; Grafana dashboards reads data from ClickHouse database; the end

cons:

- there is no official Helm chart for ClickHouse, Grafana's Helm charts are... [just look at that](https://github.com/grafana/helm-charts/blob/main/charts/grafana/templates/_pod.tpl). I wrote own charts

```
$ kubectl get pod --all-namespaces
NAMESPACE                        NAME                                                       READY   STATUS    RESTARTS        AGE
o11y-clickhouse                  clickhouse-0                                               1/1     Running   0               2m22s
o11y-grafana                     grafana-5d9c87c848-wkbnf                                   1/1     Running   0               105s
o11y-grafana                     grafana-postgres-0                                         1/1     Running   0               2m22s

$ kubectl top pod --all-namespaces
NAMESPACE                        NAME                                                       CPU(cores)   MEMORY(bytes)
o11y-clickhouse                  clickhouse-0                                               132m         295Mi
o11y-grafana                     grafana-5d9c87c848-wkbnf                                   19m          134Mi
o11y-grafana                     grafana-postgres-0                                         17m          59Mi
```

## Decision Outcome

Grafana and ClickHouse seems to be perfect combination for OpenTelemetry backend. The stack is light, simple and open-source.
