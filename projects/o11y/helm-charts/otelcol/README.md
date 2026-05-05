This chart deploys OpenTelemetry collector.

ClickHouse schemas:

```
clickhouse-0.clickhouse-headless.o11y-clickhouse.svc.cluster.local :) SHOW TABLES;

SHOW TABLES

Query id: 54bdd480-410b-41ee-a843-04e242343c40

   ┌─name───────────────────────────────┐
1. │ otel_logs                          │
2. │ otel_metrics_exponential_histogram │
3. │ otel_metrics_gauge                 │
4. │ otel_metrics_histogram             │
5. │ otel_metrics_sum                   │
6. │ otel_metrics_summary               │
7. │ otel_traces                        │
8. │ otel_traces_trace_id_ts            │
9. │ otel_traces_trace_id_ts_mv         │
   └────────────────────────────────────┘

9 rows in set. Elapsed: 0.155 sec.

clickhouse-0.clickhouse-headless.o11y-clickhouse.svc.cluster.local :) SHOW CREATE TABLE otel_logs;

SHOW CREATE TABLE otel_logs

Query id: a3cf79d8-5ee0-4bed-aaf6-fff2af7a9527

   ┌─statement─────────────────────────────────────────────────────────────────────────────────────────┐
1. │ CREATE TABLE opentelemetry.otel_logs                                                             ↴│
   │↳(                                                                                                ↴│
   │↳    `Timestamp` DateTime64(9) CODEC(Delta(8), ZSTD(1)),                                          ↴│
   │↳    `TimestampTime` DateTime DEFAULT toDateTime(Timestamp),                                      ↴│
   │↳    `TraceId` String CODEC(ZSTD(1)),                                                             ↴│
   │↳    `SpanId` String CODEC(ZSTD(1)),                                                              ↴│
   │↳    `TraceFlags` UInt8,                                                                          ↴│
   │↳    `SeverityText` LowCardinality(String) CODEC(ZSTD(1)),                                        ↴│
   │↳    `SeverityNumber` UInt8,                                                                      ↴│
   │↳    `ServiceName` LowCardinality(String) CODEC(ZSTD(1)),                                         ↴│
   │↳    `Body` String CODEC(ZSTD(1)),                                                                ↴│
   │↳    `ResourceSchemaUrl` LowCardinality(String) CODEC(ZSTD(1)),                                   ↴│
   │↳    `ResourceAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                     ↴│
   │↳    `ScopeSchemaUrl` LowCardinality(String) CODEC(ZSTD(1)),                                      ↴│
   │↳    `ScopeName` String CODEC(ZSTD(1)),                                                           ↴│
   │↳    `ScopeVersion` LowCardinality(String) CODEC(ZSTD(1)),                                        ↴│
   │↳    `ScopeAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                        ↴│
   │↳    `LogAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                          ↴│
   │↳    INDEX idx_trace_id TraceId TYPE bloom_filter(0.001) GRANULARITY 1,                           ↴│
   │↳    INDEX idx_res_attr_key mapKeys(ResourceAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,    ↴│
   │↳    INDEX idx_res_attr_value mapValues(ResourceAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,↴│
   │↳    INDEX idx_scope_attr_key mapKeys(ScopeAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,     ↴│
   │↳    INDEX idx_scope_attr_value mapValues(ScopeAttributes) TYPE bloom_filter(0.01) GRANULARITY 1, ↴│
   │↳    INDEX idx_log_attr_key mapKeys(LogAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,         ↴│
   │↳    INDEX idx_log_attr_value mapValues(LogAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,     ↴│
   │↳    INDEX idx_body Body TYPE tokenbf_v1(32768, 3, 0) GRANULARITY 8                               ↴│
   │↳)                                                                                                ↴│
   │↳ENGINE = MergeTree                                                                               ↴│
   │↳PARTITION BY toDate(TimestampTime)                                                               ↴│
   │↳PRIMARY KEY (ServiceName, TimestampTime)                                                         ↴│
   │↳ORDER BY (ServiceName, TimestampTime, Timestamp)                                                 ↴│
   │↳SETTINGS index_granularity = 8192, ttl_only_drop_parts = 1                                        │
   └───────────────────────────────────────────────────────────────────────────────────────────────────┘

1 row in set. Elapsed: 0.067 sec.

clickhouse-0.clickhouse-headless.o11y-clickhouse.svc.cluster.local :) SHOW CREATE TABLE otel_metrics_exponential_histogram;

SHOW CREATE TABLE otel_metrics_exponential_histogram

Query id: 84b8e0f0-5456-4bf6-860a-1422c91b0072

   ┌─statement─────────────────────────────────────────────────────────────────────────────────────────┐
1. │ CREATE TABLE opentelemetry.otel_metrics_exponential_histogram                                    ↴│
   │↳(                                                                                                ↴│
   │↳    `ResourceAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                     ↴│
   │↳    `ResourceSchemaUrl` String CODEC(ZSTD(1)),                                                   ↴│
   │↳    `ScopeName` String CODEC(ZSTD(1)),                                                           ↴│
   │↳    `ScopeVersion` String CODEC(ZSTD(1)),                                                        ↴│
   │↳    `ScopeAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                        ↴│
   │↳    `ScopeDroppedAttrCount` UInt32 CODEC(ZSTD(1)),                                               ↴│
   │↳    `ScopeSchemaUrl` String CODEC(ZSTD(1)),                                                      ↴│
   │↳    `ServiceName` LowCardinality(String) CODEC(ZSTD(1)),                                         ↴│
   │↳    `MetricName` String CODEC(ZSTD(1)),                                                          ↴│
   │↳    `MetricDescription` String CODEC(ZSTD(1)),                                                   ↴│
   │↳    `MetricUnit` String CODEC(ZSTD(1)),                                                          ↴│
   │↳    `Attributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                             ↴│
   │↳    `StartTimeUnix` DateTime64(9) CODEC(Delta(8), ZSTD(1)),                                      ↴│
   │↳    `TimeUnix` DateTime64(9) CODEC(Delta(8), ZSTD(1)),                                           ↴│
   │↳    `Count` UInt64 CODEC(Delta(8), ZSTD(1)),                                                     ↴│
   │↳    `Sum` Float64 CODEC(ZSTD(1)),                                                                ↴│
   │↳    `Scale` Int32 CODEC(ZSTD(1)),                                                                ↴│
   │↳    `ZeroCount` UInt64 CODEC(ZSTD(1)),                                                           ↴│
   │↳    `PositiveOffset` Int32 CODEC(ZSTD(1)),                                                       ↴│
   │↳    `PositiveBucketCounts` Array(UInt64) CODEC(ZSTD(1)),                                         ↴│
   │↳    `NegativeOffset` Int32 CODEC(ZSTD(1)),                                                       ↴│
   │↳    `NegativeBucketCounts` Array(UInt64) CODEC(ZSTD(1)),                                         ↴│
   │↳    `Exemplars.FilteredAttributes` Array(Map(LowCardinality(String), String)) CODEC(ZSTD(1)),    ↴│
   │↳    `Exemplars.TimeUnix` Array(DateTime64(9)) CODEC(ZSTD(1)),                                    ↴│
   │↳    `Exemplars.Value` Array(Float64) CODEC(ZSTD(1)),                                             ↴│
   │↳    `Exemplars.SpanId` Array(String) CODEC(ZSTD(1)),                                             ↴│
   │↳    `Exemplars.TraceId` Array(String) CODEC(ZSTD(1)),                                            ↴│
   │↳    `Flags` UInt32 CODEC(ZSTD(1)),                                                               ↴│
   │↳    `Min` Float64 CODEC(ZSTD(1)),                                                                ↴│
   │↳    `Max` Float64 CODEC(ZSTD(1)),                                                                ↴│
   │↳    `AggregationTemporality` Int32 CODEC(ZSTD(1)),                                               ↴│
   │↳    INDEX idx_res_attr_key mapKeys(ResourceAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,    ↴│
   │↳    INDEX idx_res_attr_value mapValues(ResourceAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,↴│
   │↳    INDEX idx_scope_attr_key mapKeys(ScopeAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,     ↴│
   │↳    INDEX idx_scope_attr_value mapValues(ScopeAttributes) TYPE bloom_filter(0.01) GRANULARITY 1, ↴│
   │↳    INDEX idx_attr_key mapKeys(Attributes) TYPE bloom_filter(0.01) GRANULARITY 1,                ↴│
   │↳    INDEX idx_attr_value mapValues(Attributes) TYPE bloom_filter(0.01) GRANULARITY 1             ↴│
   │↳)                                                                                                ↴│
   │↳ENGINE = MergeTree                                                                               ↴│
   │↳PARTITION BY toDate(TimeUnix)                                                                    ↴│
   │↳ORDER BY (ServiceName, MetricName, Attributes, toUnixTimestamp64Nano(TimeUnix))                  ↴│
   │↳SETTINGS index_granularity = 8192, ttl_only_drop_parts = 1                                        │
   └───────────────────────────────────────────────────────────────────────────────────────────────────┘

1 row in set. Elapsed: 0.035 sec.

clickhouse-0.clickhouse-headless.o11y-clickhouse.svc.cluster.local :) SHOW CREATE TABLE otel_metrics_gauge;

SHOW CREATE TABLE otel_metrics_gauge

Query id: 08522563-4aca-4f83-ba41-519d441551ae

   ┌─statement─────────────────────────────────────────────────────────────────────────────────────────┐
1. │ CREATE TABLE opentelemetry.otel_metrics_gauge                                                    ↴│
   │↳(                                                                                                ↴│
   │↳    `ResourceAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                     ↴│
   │↳    `ResourceSchemaUrl` String CODEC(ZSTD(1)),                                                   ↴│
   │↳    `ScopeName` String CODEC(ZSTD(1)),                                                           ↴│
   │↳    `ScopeVersion` String CODEC(ZSTD(1)),                                                        ↴│
   │↳    `ScopeAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                        ↴│
   │↳    `ScopeDroppedAttrCount` UInt32 CODEC(ZSTD(1)),                                               ↴│
   │↳    `ScopeSchemaUrl` String CODEC(ZSTD(1)),                                                      ↴│
   │↳    `ServiceName` LowCardinality(String) CODEC(ZSTD(1)),                                         ↴│
   │↳    `MetricName` String CODEC(ZSTD(1)),                                                          ↴│
   │↳    `MetricDescription` String CODEC(ZSTD(1)),                                                   ↴│
   │↳    `MetricUnit` String CODEC(ZSTD(1)),                                                          ↴│
   │↳    `Attributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                             ↴│
   │↳    `StartTimeUnix` DateTime64(9) CODEC(Delta(8), ZSTD(1)),                                      ↴│
   │↳    `TimeUnix` DateTime64(9) CODEC(Delta(8), ZSTD(1)),                                           ↴│
   │↳    `Value` Float64 CODEC(ZSTD(1)),                                                              ↴│
   │↳    `Flags` UInt32 CODEC(ZSTD(1)),                                                               ↴│
   │↳    `Exemplars.FilteredAttributes` Array(Map(LowCardinality(String), String)) CODEC(ZSTD(1)),    ↴│
   │↳    `Exemplars.TimeUnix` Array(DateTime64(9)) CODEC(ZSTD(1)),                                    ↴│
   │↳    `Exemplars.Value` Array(Float64) CODEC(ZSTD(1)),                                             ↴│
   │↳    `Exemplars.SpanId` Array(String) CODEC(ZSTD(1)),                                             ↴│
   │↳    `Exemplars.TraceId` Array(String) CODEC(ZSTD(1)),                                            ↴│
   │↳    INDEX idx_res_attr_key mapKeys(ResourceAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,    ↴│
   │↳    INDEX idx_res_attr_value mapValues(ResourceAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,↴│
   │↳    INDEX idx_scope_attr_key mapKeys(ScopeAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,     ↴│
   │↳    INDEX idx_scope_attr_value mapValues(ScopeAttributes) TYPE bloom_filter(0.01) GRANULARITY 1, ↴│
   │↳    INDEX idx_attr_key mapKeys(Attributes) TYPE bloom_filter(0.01) GRANULARITY 1,                ↴│
   │↳    INDEX idx_attr_value mapValues(Attributes) TYPE bloom_filter(0.01) GRANULARITY 1             ↴│
   │↳)                                                                                                ↴│
   │↳ENGINE = MergeTree                                                                               ↴│
   │↳PARTITION BY toDate(TimeUnix)                                                                    ↴│
   │↳ORDER BY (ServiceName, MetricName, Attributes, toUnixTimestamp64Nano(TimeUnix))                  ↴│
   │↳SETTINGS index_granularity = 8192, ttl_only_drop_parts = 1                                        │
   └───────────────────────────────────────────────────────────────────────────────────────────────────┘

1 row in set. Elapsed: 0.122 sec.

clickhouse-0.clickhouse-headless.o11y-clickhouse.svc.cluster.local :) SHOW CREATE TABLE otel_metrics_histogram;

SHOW CREATE TABLE otel_metrics_histogram

Query id: e286819d-4d24-4232-b8b9-c0724987c89e

   ┌─statement─────────────────────────────────────────────────────────────────────────────────────────┐
1. │ CREATE TABLE opentelemetry.otel_metrics_histogram                                                ↴│
   │↳(                                                                                                ↴│
   │↳    `ResourceAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                     ↴│
   │↳    `ResourceSchemaUrl` String CODEC(ZSTD(1)),                                                   ↴│
   │↳    `ScopeName` String CODEC(ZSTD(1)),                                                           ↴│
   │↳    `ScopeVersion` String CODEC(ZSTD(1)),                                                        ↴│
   │↳    `ScopeAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                        ↴│
   │↳    `ScopeDroppedAttrCount` UInt32 CODEC(ZSTD(1)),                                               ↴│
   │↳    `ScopeSchemaUrl` String CODEC(ZSTD(1)),                                                      ↴│
   │↳    `ServiceName` LowCardinality(String) CODEC(ZSTD(1)),                                         ↴│
   │↳    `MetricName` String CODEC(ZSTD(1)),                                                          ↴│
   │↳    `MetricDescription` String CODEC(ZSTD(1)),                                                   ↴│
   │↳    `MetricUnit` String CODEC(ZSTD(1)),                                                          ↴│
   │↳    `Attributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                             ↴│
   │↳    `StartTimeUnix` DateTime64(9) CODEC(Delta(8), ZSTD(1)),                                      ↴│
   │↳    `TimeUnix` DateTime64(9) CODEC(Delta(8), ZSTD(1)),                                           ↴│
   │↳    `Count` UInt64 CODEC(Delta(8), ZSTD(1)),                                                     ↴│
   │↳    `Sum` Float64 CODEC(ZSTD(1)),                                                                ↴│
   │↳    `BucketCounts` Array(UInt64) CODEC(ZSTD(1)),                                                 ↴│
   │↳    `ExplicitBounds` Array(Float64) CODEC(ZSTD(1)),                                              ↴│
   │↳    `Exemplars.FilteredAttributes` Array(Map(LowCardinality(String), String)) CODEC(ZSTD(1)),    ↴│
   │↳    `Exemplars.TimeUnix` Array(DateTime64(9)) CODEC(ZSTD(1)),                                    ↴│
   │↳    `Exemplars.Value` Array(Float64) CODEC(ZSTD(1)),                                             ↴│
   │↳    `Exemplars.SpanId` Array(String) CODEC(ZSTD(1)),                                             ↴│
   │↳    `Exemplars.TraceId` Array(String) CODEC(ZSTD(1)),                                            ↴│
   │↳    `Flags` UInt32 CODEC(ZSTD(1)),                                                               ↴│
   │↳    `Min` Float64 CODEC(ZSTD(1)),                                                                ↴│
   │↳    `Max` Float64 CODEC(ZSTD(1)),                                                                ↴│
   │↳    `AggregationTemporality` Int32 CODEC(ZSTD(1)),                                               ↴│
   │↳    INDEX idx_res_attr_key mapKeys(ResourceAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,    ↴│
   │↳    INDEX idx_res_attr_value mapValues(ResourceAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,↴│
   │↳    INDEX idx_scope_attr_key mapKeys(ScopeAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,     ↴│
   │↳    INDEX idx_scope_attr_value mapValues(ScopeAttributes) TYPE bloom_filter(0.01) GRANULARITY 1, ↴│
   │↳    INDEX idx_attr_key mapKeys(Attributes) TYPE bloom_filter(0.01) GRANULARITY 1,                ↴│
   │↳    INDEX idx_attr_value mapValues(Attributes) TYPE bloom_filter(0.01) GRANULARITY 1             ↴│
   │↳)                                                                                                ↴│
   │↳ENGINE = MergeTree                                                                               ↴│
   │↳PARTITION BY toDate(TimeUnix)                                                                    ↴│
   │↳ORDER BY (ServiceName, MetricName, Attributes, toUnixTimestamp64Nano(TimeUnix))                  ↴│
   │↳SETTINGS index_granularity = 8192, ttl_only_drop_parts = 1                                        │
   └───────────────────────────────────────────────────────────────────────────────────────────────────┘

1 row in set. Elapsed: 0.019 sec.

clickhouse-0.clickhouse-headless.o11y-clickhouse.svc.cluster.local :) SHOW CREATE TABLE otel_metrics_sum;

SHOW CREATE TABLE otel_metrics_sum

Query id: d1de7cb9-a53d-497c-8e3c-e3a3e176904e

   ┌─statement─────────────────────────────────────────────────────────────────────────────────────────┐
1. │ CREATE TABLE opentelemetry.otel_metrics_sum                                                      ↴│
   │↳(                                                                                                ↴│
   │↳    `ResourceAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                     ↴│
   │↳    `ResourceSchemaUrl` String CODEC(ZSTD(1)),                                                   ↴│
   │↳    `ScopeName` String CODEC(ZSTD(1)),                                                           ↴│
   │↳    `ScopeVersion` String CODEC(ZSTD(1)),                                                        ↴│
   │↳    `ScopeAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                        ↴│
   │↳    `ScopeDroppedAttrCount` UInt32 CODEC(ZSTD(1)),                                               ↴│
   │↳    `ScopeSchemaUrl` String CODEC(ZSTD(1)),                                                      ↴│
   │↳    `ServiceName` LowCardinality(String) CODEC(ZSTD(1)),                                         ↴│
   │↳    `MetricName` String CODEC(ZSTD(1)),                                                          ↴│
   │↳    `MetricDescription` String CODEC(ZSTD(1)),                                                   ↴│
   │↳    `MetricUnit` String CODEC(ZSTD(1)),                                                          ↴│
   │↳    `Attributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                             ↴│
   │↳    `StartTimeUnix` DateTime64(9) CODEC(Delta(8), ZSTD(1)),                                      ↴│
   │↳    `TimeUnix` DateTime64(9) CODEC(Delta(8), ZSTD(1)),                                           ↴│
   │↳    `Value` Float64 CODEC(ZSTD(1)),                                                              ↴│
   │↳    `Flags` UInt32 CODEC(ZSTD(1)),                                                               ↴│
   │↳    `Exemplars.FilteredAttributes` Array(Map(LowCardinality(String), String)) CODEC(ZSTD(1)),    ↴│
   │↳    `Exemplars.TimeUnix` Array(DateTime64(9)) CODEC(ZSTD(1)),                                    ↴│
   │↳    `Exemplars.Value` Array(Float64) CODEC(ZSTD(1)),                                             ↴│
   │↳    `Exemplars.SpanId` Array(String) CODEC(ZSTD(1)),                                             ↴│
   │↳    `Exemplars.TraceId` Array(String) CODEC(ZSTD(1)),                                            ↴│
   │↳    `AggregationTemporality` Int32 CODEC(ZSTD(1)),                                               ↴│
   │↳    `IsMonotonic` Bool CODEC(Delta(1), ZSTD(1)),                                                 ↴│
   │↳    INDEX idx_res_attr_key mapKeys(ResourceAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,    ↴│
   │↳    INDEX idx_res_attr_value mapValues(ResourceAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,↴│
   │↳    INDEX idx_scope_attr_key mapKeys(ScopeAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,     ↴│
   │↳    INDEX idx_scope_attr_value mapValues(ScopeAttributes) TYPE bloom_filter(0.01) GRANULARITY 1, ↴│
   │↳    INDEX idx_attr_key mapKeys(Attributes) TYPE bloom_filter(0.01) GRANULARITY 1,                ↴│
   │↳    INDEX idx_attr_value mapValues(Attributes) TYPE bloom_filter(0.01) GRANULARITY 1             ↴│
   │↳)                                                                                                ↴│
   │↳ENGINE = MergeTree                                                                               ↴│
   │↳PARTITION BY toDate(TimeUnix)                                                                    ↴│
   │↳ORDER BY (ServiceName, MetricName, Attributes, toUnixTimestamp64Nano(TimeUnix))                  ↴│
   │↳SETTINGS index_granularity = 8192, ttl_only_drop_parts = 1                                        │
   └───────────────────────────────────────────────────────────────────────────────────────────────────┘

1 row in set. Elapsed: 0.023 sec.

clickhouse-0.clickhouse-headless.o11y-clickhouse.svc.cluster.local :) SHOW CREATE TABLE otel_metrics_summary;

SHOW CREATE TABLE otel_metrics_summary

Query id: e4a6e051-6016-4e1a-86f8-c4da07090399

   ┌─statement─────────────────────────────────────────────────────────────────────────────────────────┐
1. │ CREATE TABLE opentelemetry.otel_metrics_summary                                                  ↴│
   │↳(                                                                                                ↴│
   │↳    `ResourceAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                     ↴│
   │↳    `ResourceSchemaUrl` String CODEC(ZSTD(1)),                                                   ↴│
   │↳    `ScopeName` String CODEC(ZSTD(1)),                                                           ↴│
   │↳    `ScopeVersion` String CODEC(ZSTD(1)),                                                        ↴│
   │↳    `ScopeAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                        ↴│
   │↳    `ScopeDroppedAttrCount` UInt32 CODEC(ZSTD(1)),                                               ↴│
   │↳    `ScopeSchemaUrl` String CODEC(ZSTD(1)),                                                      ↴│
   │↳    `ServiceName` LowCardinality(String) CODEC(ZSTD(1)),                                         ↴│
   │↳    `MetricName` String CODEC(ZSTD(1)),                                                          ↴│
   │↳    `MetricDescription` String CODEC(ZSTD(1)),                                                   ↴│
   │↳    `MetricUnit` String CODEC(ZSTD(1)),                                                          ↴│
   │↳    `Attributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                             ↴│
   │↳    `StartTimeUnix` DateTime64(9) CODEC(Delta(8), ZSTD(1)),                                      ↴│
   │↳    `TimeUnix` DateTime64(9) CODEC(Delta(8), ZSTD(1)),                                           ↴│
   │↳    `Count` UInt64 CODEC(Delta(8), ZSTD(1)),                                                     ↴│
   │↳    `Sum` Float64 CODEC(ZSTD(1)),                                                                ↴│
   │↳    `ValueAtQuantiles.Quantile` Array(Float64) CODEC(ZSTD(1)),                                   ↴│
   │↳    `ValueAtQuantiles.Value` Array(Float64) CODEC(ZSTD(1)),                                      ↴│
   │↳    `Flags` UInt32 CODEC(ZSTD(1)),                                                               ↴│
   │↳    INDEX idx_res_attr_key mapKeys(ResourceAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,    ↴│
   │↳    INDEX idx_res_attr_value mapValues(ResourceAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,↴│
   │↳    INDEX idx_scope_attr_key mapKeys(ScopeAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,     ↴│
   │↳    INDEX idx_scope_attr_value mapValues(ScopeAttributes) TYPE bloom_filter(0.01) GRANULARITY 1, ↴│
   │↳    INDEX idx_attr_key mapKeys(Attributes) TYPE bloom_filter(0.01) GRANULARITY 1,                ↴│
   │↳    INDEX idx_attr_value mapValues(Attributes) TYPE bloom_filter(0.01) GRANULARITY 1             ↴│
   │↳)                                                                                                ↴│
   │↳ENGINE = MergeTree                                                                               ↴│
   │↳PARTITION BY toDate(TimeUnix)                                                                    ↴│
   │↳ORDER BY (ServiceName, MetricName, Attributes, toUnixTimestamp64Nano(TimeUnix))                  ↴│
   │↳SETTINGS index_granularity = 8192, ttl_only_drop_parts = 1                                        │
   └───────────────────────────────────────────────────────────────────────────────────────────────────┘

1 row in set. Elapsed: 0.205 sec.

clickhouse-0.clickhouse-headless.o11y-clickhouse.svc.cluster.local :) SHOW CREATE TABLE otel_traces;

SHOW CREATE TABLE otel_traces

Query id: 0d50831a-55bb-404c-940c-d95dcfa990bd

   ┌─statement─────────────────────────────────────────────────────────────────────────────────────────┐
1. │ CREATE TABLE opentelemetry.otel_traces                                                           ↴│
   │↳(                                                                                                ↴│
   │↳    `Timestamp` DateTime64(9) CODEC(Delta(8), ZSTD(1)),                                          ↴│
   │↳    `TraceId` String CODEC(ZSTD(1)),                                                             ↴│
   │↳    `SpanId` String CODEC(ZSTD(1)),                                                              ↴│
   │↳    `ParentSpanId` String CODEC(ZSTD(1)),                                                        ↴│
   │↳    `TraceState` String CODEC(ZSTD(1)),                                                          ↴│
   │↳    `SpanName` LowCardinality(String) CODEC(ZSTD(1)),                                            ↴│
   │↳    `SpanKind` LowCardinality(String) CODEC(ZSTD(1)),                                            ↴│
   │↳    `ServiceName` LowCardinality(String) CODEC(ZSTD(1)),                                         ↴│
   │↳    `ResourceAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                     ↴│
   │↳    `ScopeName` String CODEC(ZSTD(1)),                                                           ↴│
   │↳    `ScopeVersion` String CODEC(ZSTD(1)),                                                        ↴│
   │↳    `SpanAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),                         ↴│
   │↳    `Duration` UInt64 CODEC(ZSTD(1)),                                                            ↴│
   │↳    `StatusCode` LowCardinality(String) CODEC(ZSTD(1)),                                          ↴│
   │↳    `StatusMessage` String CODEC(ZSTD(1)),                                                       ↴│
   │↳    `Events.Timestamp` Array(DateTime64(9)) CODEC(ZSTD(1)),                                      ↴│
   │↳    `Events.Name` Array(LowCardinality(String)) CODEC(ZSTD(1)),                                  ↴│
   │↳    `Events.Attributes` Array(Map(LowCardinality(String), String)) CODEC(ZSTD(1)),               ↴│
   │↳    `Links.TraceId` Array(String) CODEC(ZSTD(1)),                                                ↴│
   │↳    `Links.SpanId` Array(String) CODEC(ZSTD(1)),                                                 ↴│
   │↳    `Links.TraceState` Array(String) CODEC(ZSTD(1)),                                             ↴│
   │↳    `Links.Attributes` Array(Map(LowCardinality(String), String)) CODEC(ZSTD(1)),                ↴│
   │↳    INDEX idx_trace_id TraceId TYPE bloom_filter(0.001) GRANULARITY 1,                           ↴│
   │↳    INDEX idx_res_attr_key mapKeys(ResourceAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,    ↴│
   │↳    INDEX idx_res_attr_value mapValues(ResourceAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,↴│
   │↳    INDEX idx_span_attr_key mapKeys(SpanAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,       ↴│
   │↳    INDEX idx_span_attr_value mapValues(SpanAttributes) TYPE bloom_filter(0.01) GRANULARITY 1,   ↴│
   │↳    INDEX idx_duration Duration TYPE minmax GRANULARITY 1                                        ↴│
   │↳)                                                                                                ↴│
   │↳ENGINE = MergeTree                                                                               ↴│
   │↳PARTITION BY toDate(Timestamp)                                                                   ↴│
   │↳ORDER BY (ServiceName, SpanName, toDateTime(Timestamp))                                          ↴│
   │↳SETTINGS index_granularity = 8192, ttl_only_drop_parts = 1                                        │
   └───────────────────────────────────────────────────────────────────────────────────────────────────┘

1 row in set. Elapsed: 0.021 sec.

clickhouse-0.clickhouse-headless.o11y-clickhouse.svc.cluster.local :) SHOW CREATE TABLE otel_traces_trace_id_ts;

SHOW CREATE TABLE otel_traces_trace_id_ts

Query id: fdc93372-6f01-40b6-9a48-5ea1b08ed389

   ┌─statement────────────────────────────────────────────────────────────┐
1. │ CREATE TABLE opentelemetry.otel_traces_trace_id_ts                  ↴│
   │↳(                                                                   ↴│
   │↳    `TraceId` String CODEC(ZSTD(1)),                                ↴│
   │↳    `Start` DateTime CODEC(Delta(4), ZSTD(1)),                      ↴│
   │↳    `End` DateTime CODEC(Delta(4), ZSTD(1)),                        ↴│
   │↳    INDEX idx_trace_id TraceId TYPE bloom_filter(0.01) GRANULARITY 1↴│
   │↳)                                                                   ↴│
   │↳ENGINE = MergeTree                                                  ↴│
   │↳PARTITION BY toDate(Start)                                          ↴│
   │↳ORDER BY (TraceId, Start)                                           ↴│
   │↳SETTINGS index_granularity = 8192, ttl_only_drop_parts = 1           │
   └──────────────────────────────────────────────────────────────────────┘

1 row in set. Elapsed: 0.024 sec.

clickhouse-0.clickhouse-headless.o11y-clickhouse.svc.cluster.local :) SHOW CREATE TABLE otel_traces_trace_id_ts_mv;

SHOW CREATE TABLE otel_traces_trace_id_ts_mv

Query id: 3b127937-297a-408f-b64c-48eec5c244d0

   ┌─statement──────────────────────────────────────────────────────────────────────────────────────────────────┐
1. │ CREATE MATERIALIZED VIEW opentelemetry.otel_traces_trace_id_ts_mv TO opentelemetry.otel_traces_trace_id_ts↴│
   │↳(                                                                                                         ↴│
   │↳    `TraceId` String,                                                                                     ↴│
   │↳    `Start` DateTime64(9),                                                                                ↴│
   │↳    `End` DateTime64(9)                                                                                   ↴│
   │↳)                                                                                                         ↴│
   │↳AS SELECT                                                                                                 ↴│
   │↳    TraceId,                                                                                              ↴│
   │↳    min(Timestamp) AS Start,                                                                              ↴│
   │↳    max(Timestamp) AS End                                                                                 ↴│
   │↳FROM opentelemetry.otel_traces                                                                            ↴│
   │↳WHERE TraceId != ''                                                                                       ↴│
   │↳GROUP BY TraceId                                                                                           │
   └────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

1 row in set. Elapsed: 0.031 sec.
```
