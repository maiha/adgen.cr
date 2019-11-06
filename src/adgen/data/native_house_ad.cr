class Adgen::NativeHouseAd
  JSON.mapping({
    publisher_id:        Int64         , # 0
    adsvr_schedule_id:   Int64?        , # 0
    adsvr_schedule_name: String?       , # "string"
    house_ad_creatives:  Array(NativeHouseAdCreative) , #
  })

  def to_pb
    Adgen::Proto::NativeHouseAd.new(
      publisher_id: publisher_id,
      adsvr_schedule_id: adsvr_schedule_id,
      adsvr_schedule_name: adsvr_schedule_name,
      house_ad_creatives: house_ad_creatives.map(&.to_pb),
    )
  end
end
