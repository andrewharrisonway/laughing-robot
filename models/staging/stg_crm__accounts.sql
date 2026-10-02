WITH

raw_input AS (
    SELECT *
    FROM
        {{ source('raw', 'raw_accounts') }}
)

, typed AS (
    SELECT
        CAST(account_id AS VARCHAR) AS account_id
        , CAST(company_name AS VARCHAR) AS company_name
        , CAST(tier AS VARCHAR) AS tier
        , CAST(created_at AS TIMESTAMP) AS created_at
    FROM raw_input
)

SELECT * FROM typed
