WITH

raw_input AS (
    SELECT *
    FROM
        {{ source('raw', 'raw_subscriptions') }}
)

, typed AS (
    SELECT
        CAST(subscription_id AS VARCHAR) AS subscription_id
        , CAST(account_id AS VARCHAR) AS account_id
        , CAST(plan_id AS VARCHAR) AS plan_id
        , CAST(mrr_amount AS DECIMAL(12, 2)) AS mrr_amount
        , CAST(status AS VARCHAR) AS status
        , CAST(start_date AS DATE) AS start_date
        , CAST(end_date AS DATE) AS end_date
    FROM raw_input
)

SELECT * FROM typed
