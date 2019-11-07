CREATE TABLE adsvr_creative_house (
  publisher_id Int64,
  adsvr_schedule_id Nullable(Int64),
  adsvr_schedule_name Nullable(String),
  adsvr_creative_id Nullable(Int64),
  adsvr_creative_name Nullable(String),
  native_title Nullable(String),
  native_sponsored Nullable(String),
  native_ctatext Nullable(String),
  main_image Nullable(String),
  icon_image Nullable(String)
)
ENGINE = Log
