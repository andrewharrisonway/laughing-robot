{# event_ids to leave out of this model. Add ids to the list. #}
{%- set event_exceptions = ['evt_99999'] %} {# no user_id, event_id number value is not within expectations #}
{%- set account_exceptions = ['acc_105'] %} {# account_id not unique. Split across 2 #}

WITH

raw_input AS (
    SELECT *
    FROM
        {{ source('raw', 'raw_events') }}
    WHERE
        TRUE
    {% if event_exceptions %}
    AND
        event_id NOT IN ('{{ event_exceptions | join("', '") }}')
    {% endif %}
    {% if account_exceptions %}
    AND
        account_id NOT IN ('{{ account_exceptions | join("', '") }}')
    {% endif %}
)

, typed AS (
    SELECT
        CAST("event_id" AS VARCHAR) AS event_id
        , CAST("account_id" AS VARCHAR) AS account_id
        , CAST("user_id" AS VARCHAR) AS user_id
        , CAST("event_name" AS VARCHAR) AS event_name
        -- NOTE: renamed from `timestamp`, a reserved type name
        , CAST("timestamp" AS TIMESTAMP) AS event_at
    FROM raw_input
)

SELECT * FROM typed
