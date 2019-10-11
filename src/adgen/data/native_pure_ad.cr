class Adgen::NativePureAd
  JSON.mapping({
    publisher_id:        Int64         , # 0
    adsvr_schedule_id:   Int64?        , # 0
    adsvr_schedule_name: String?       , # "string"
    pure_ad_budget:      NativePureAdBudget?,
    pure_ad_creatives:   Array(NativePureAdCreative),
  })

  def to_pb
    Adgen::Proto::NativePureAd.new(
      publisher_id: publisher_id,
      adsvr_schedule_id: adsvr_schedule_id,
      adsvr_schedule_name: adsvr_schedule_name,
      pure_ad_budget: pure_ad_budget.try(&.to_pb),
      pure_ad_creatives: pure_ad_creatives.map(&.to_pb),
    )
  end
end
