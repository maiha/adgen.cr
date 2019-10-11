struct Adgen::Proto::NativePureAd
  def to_s(io : IO)
    adsvr_schedule = "%s(%s)" % [adsvr_schedule_name.inspect, adsvr_schedule_id]
    creative_cnt = pure_ad_creatives.try(&.size) || 0
    io << "NativePureAd(publisher_id=#{publisher_id}, #{adsvr_schedule}, #{creative_cnt} creatives)"
  end
end
