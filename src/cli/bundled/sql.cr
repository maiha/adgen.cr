module Bundled
  SQL = {
    # main models
    "native_pure_ad" => {{ system("cat src/cli/bundled/sql/native_pure_ad.sql").stringify }},
    
    # application data
    "snap" => {{ system("cat src/cli/bundled/sql/snap.sql").stringify }},
  }
end
