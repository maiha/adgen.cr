struct Adgen::Proto::NativeHouseAd
  def creatives : Array(Adgen::Proto::NativeHouseAdCreative)
    house_ad_creatives || Array(Adgen::Proto::NativeHouseAdCreative).new
  end

  def to_s(io : IO)
    adsvr_schedule = "%s(%s)" % [adsvr_schedule_name.inspect, adsvr_schedule_id]
    io << "NativeHouseAd(publisher_id=#{publisher_id}, #{adsvr_schedule}, #{creatives.size} creatives)"
  end
end
