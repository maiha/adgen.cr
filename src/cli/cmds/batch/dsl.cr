class Cmds::BatchCmd
  # models that belongs to publisher
  publisher_model NativePureAd
  publisher_model NativeHouseAd

  PUBLISHER_MODEL_NAMES = {{PUBLISHER_MODEL_CLASS_IDS.map(&.stringify)}}
end
