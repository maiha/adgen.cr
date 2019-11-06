struct Adgen::Proto::NativePureAd
  def creatives : Array(Adgen::Proto::NativePureAdCreative)
    pure_ad_creatives || Array(Adgen::Proto::NativePureAdCreative).new
  end

  def to_s(io : IO)
    adsvr_schedule = "%s(%s)" % [adsvr_schedule_name.inspect, adsvr_schedule_id]
    io << "NativePureAd(publisher_id=#{publisher_id}, #{adsvr_schedule}, #{creatives.size} creatives)"
  end
end
