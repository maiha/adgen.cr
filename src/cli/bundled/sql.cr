module Bundled
  SQL = {
    # tsv
    "adsvr_creative" => {{ system("cat src/cli/bundled/sql/adsvr_creative.sql").stringify }},
  }
end
