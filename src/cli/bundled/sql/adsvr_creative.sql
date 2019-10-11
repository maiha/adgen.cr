CREATE TABLE adsvr_creative (
  publisher_id Int64,
  adsvr_schedule_id Nullable(Int64),
  adsvr_schedule_name Nullable(String),
  budget_type Nullable(String),
  lifetime_budget_impression Nullable(Int64),
  monthly_budget_impression Nullable(Int64),
  daily_budget_impression Nullable(Int64),
  lifetime_budget_click Nullable(Int64),
  monthly_budget_click Nullable(Int64),
  daily_budget_click Nullable(Int64),
  adsvr_creative_id Nullable(Int64),
  adsvr_creative_name Nullable(String),
  native_title Nullable(String),
  native_sponsored Nullable(String),
  native_ctatext Nullable(String)
)
ENGINE = Log
