FROM grafana/grafana:13.0

ENV TZ="UTC"

RUN grafana cli plugins install grafana-clickhouse-datasource \
&& grafana cli plugins install googlecloud-logging-datasource \
&& grafana cli plugins install googlecloud-trace-datasource
