WITH

raw_input AS (
    SELECT *
    FROM
        {{ source('raw', 'raw_accounts') }}
)

, typed AS (
    SELECT
        CAST("account_id" AS VARCHAR) AS account_id
        , CAST("company_name" AS VARCHAR) AS company_name
        -- NOTE: the export mixes casing ('mid-market', 'smb'); map each tier
        -- to one spelling. Anything unrecognised passes through unchanged so
        -- the accepted_values test catches it.
        , CAST(
            CASE LOWER(TRIM("tier"))
                WHEN 'enterprise' THEN 'Enterprise'
                WHEN 'mid-market' THEN 'Mid-Market'
                WHEN 'smb' THEN 'SMB'
                ELSE "tier"
            END AS VARCHAR
        ) AS tier
        , CAST("created_at" AS TIMESTAMP) AS created_at
    FROM raw_input
)

SELECT * FROM typed
