-- 1. Application error rate (time series).
SELECT
  TIMESTAMP_TRUNC(timestamp, MINUTE) AS time,
  COUNTIF(
    severity = 'ERROR'
    OR REGEXP_CONTAINS(IFNULL(textPayload, ''), r'(?i)error|failure')
  ) AS errors
FROM `project-f0424c60-4a52-470d-b10.gke_logs.stderr`
WHERE $__timeFilter(timestamp)
GROUP BY time
ORDER BY time;

-- 2. Pod events by namespace (table).
SELECT
  COALESCE(
    NULLIF(resource.labels.namespace_name, ''),
    NULLIF(JSON_VALUE(TO_JSON_STRING(jsonPayload), '$.metadata.namespace'), ''),
    NULLIF(JSON_VALUE(TO_JSON_STRING(jsonPayload), '$.involvedObject.namespace'), '')
  ) AS namespace,
  COUNT(*) AS events
FROM `project-f0424c60-4a52-470d-b10.gke_logs.events`
WHERE $__timeFilter(timestamp)
GROUP BY namespace
HAVING namespace IS NOT NULL AND namespace != ''
ORDER BY events DESC;

-- 3. Latency percentiles (table).
WITH samples AS (
  SELECT
    SAFE_CAST(
      REGEXP_EXTRACT(
        COALESCE(textPayload, TO_JSON_STRING(jsonPayload)),
        r'"latency_ms"\s*:\s*([0-9]+)'
      ) AS INT64
    ) AS latency_ms
  FROM `project-f0424c60-4a52-470d-b10.gke_logs.stdout`
  WHERE $__timeFilter(timestamp)
)
SELECT
  APPROX_QUANTILES(latency_ms, 100)[OFFSET(50)] AS p50_ms,
  APPROX_QUANTILES(latency_ms, 100)[OFFSET(95)] AS p95_ms,
  APPROX_QUANTILES(latency_ms, 100)[OFFSET(99)] AS p99_ms
FROM samples
WHERE latency_ms IS NOT NULL;

-- 4. CPU percent and memory MiB (time series).
SELECT
  TIMESTAMP_TRUNC(timestamp, MINUTE) AS time,
  AVG(
    SAFE_CAST(
      REGEXP_EXTRACT(
        COALESCE(textPayload, TO_JSON_STRING(jsonPayload)),
        r'"cpu_pct"\s*:\s*([0-9]+)'
      ) AS FLOAT64
    )
  ) AS cpu_pct,
  AVG(
    SAFE_CAST(
      REGEXP_EXTRACT(
        COALESCE(textPayload, TO_JSON_STRING(jsonPayload)),
        r'"memory_mib"\s*:\s*([0-9]+)'
      ) AS FLOAT64
    )
  ) AS memory_mib
FROM `project-f0424c60-4a52-470d-b10.gke_logs.stdout`
WHERE $__timeFilter(timestamp)
GROUP BY time
HAVING cpu_pct IS NOT NULL
ORDER BY time;