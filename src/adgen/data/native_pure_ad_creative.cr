class Adgen::NativePureAdCreative
  JSON.mapping({
    adsvr_creative_id:   Int64?  , # 6877
    adsvr_creative_name: String? , # "P-プレビューテスト(119)"
    native_title:        String? , # "広告タイトル 必須"
    native_sponsored:    String? , # "広告主名"
    native_ctatext:      String? , # "CTAボタン"
    main_image:          String? , # "xxx"
    icon_image:          String? , # "yyy"
  })

  def to_pb
    Adgen::Proto::NativePureAdCreative.new(
      adsvr_creative_id: adsvr_creative_id,
      adsvr_creative_name: adsvr_creative_name,
      native_title: native_title,
      native_sponsored: native_sponsored,
      native_ctatext: native_ctatext,
      main_image: main_image,
      icon_image: icon_image,
    )
  end
end
