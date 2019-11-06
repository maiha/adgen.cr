class Adgen::NativeHouseAdCreative
  JSON.mapping({
    adsvr_creative_id:   Int64?  , # 6447
    adsvr_creative_name: String? , # "H-ネイティブ(408)"
    native_title:        String? , # "広告タイトル"
    native_sponsored:    String? , # "広告主"
    native_ctatext:      String? , # "インストールする"
    main_image:          String? , # "http..."
    icon_image:          String? , # "http..."
  })

  def to_pb
    Adgen::Proto::NativeHouseAdCreative.new(
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
