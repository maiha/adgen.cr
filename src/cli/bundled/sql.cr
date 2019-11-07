module Bundled
  SQL = {
    # tsv
    "adsvr_creative"       => {{ system("cat src/cli/bundled/sql/adsvr_creative.sql").stringify }},
    "adsvr_creative_pure"  => {{ system("cat src/cli/bundled/sql/adsvr_creative_pure.sql").stringify }},
    "adsvr_creative_house" => {{ system("cat src/cli/bundled/sql/adsvr_creative_house.sql").stringify }},
  }
end
