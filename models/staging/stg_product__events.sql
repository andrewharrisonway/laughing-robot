WITH

raw_input AS (
    SELECT *
    FROM
        {{ source('raw', 'raw_events') }}
)

, typed AS (
    SELECT
        CAST(event_id AS VARCHAR) AS event_id
        , CAST(account_id AS VARCHAR) AS account_id
        , CAST(user_id AS VARCHAR) AS user_id
        , CAST(event_name AS VARCHAR) AS event_name
        -- NOTE: renamed from `timestamp`, a reserved type name
        , CAST(timestamp AS TIMESTAMP) AS event_at
    FROM raw_input
)

SELECT * FROM typed
