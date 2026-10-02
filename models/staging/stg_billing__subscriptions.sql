{#- subscription_ids to leave out of this model. Add ids to the list. -#}
{%- set subscription_exceptions = ['sub_9999'] %} {# fails FK test to accounts #}
{%- set account_exceptions = ['acc_105'] %} {# fails FK test to accounts #}

WITH

raw_input AS (
    SELECT *
    FROM
        {{ source('raw', 'raw_subscriptions') }}
    WHERE
        TRUE
    {% if subscription_exceptions %}
    AND
        subscription_id NOT IN ('{{ subscription_exceptions | join("', '") }}')
    {% endif %}
    {% if account_exceptions %}
    AND
        account_id NOT IN ('{{ account_exceptions | join("', '") }}')
    {% endif %}
)

, typed AS (
    SELECT
        CAST("subscription_id" AS VARCHAR) AS subscription_id
        , CAST("account_id" AS VARCHAR) AS account_id
        , CAST("plan_id" AS VARCHAR) AS plan_id
        , CAST("mrr_amount" AS DECIMAL(12, 2)) AS mrr_amount
        , CAST("status" AS VARCHAR) AS subscription_status
        , CAST("start_date" AS DATE) AS subscription_start_date
        , CAST("end_date" AS DATE) AS subscription_end_date
    FROM raw_input
)

SELECT * FROM typed
