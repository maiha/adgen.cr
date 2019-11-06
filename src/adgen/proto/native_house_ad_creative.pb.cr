## Generated from adgen/native_house_ad_creative.proto
require "protobuf"

module Adgen
  module Proto
    
    struct NativeHouseAdCreative
      include Protobuf::Message
      
      contract_of "proto2" do
        optional :adsvr_creative_id, :int64, 1
        optional :adsvr_creative_name, :string, 2
        optional :native_title, :string, 3
        optional :native_sponsored, :string, 4
        optional :native_ctatext, :string, 5
        optional :main_image, :string, 6
        optional :icon_image, :string, 7
      end
    end
    
    struct NativeHouseAdCreativeArray
      include Protobuf::Message
      
      contract_of "proto2" do
        repeated :array, NativeHouseAdCreative, 1
      end
    end
    end
  end
