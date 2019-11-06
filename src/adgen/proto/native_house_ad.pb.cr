## Generated from adgen/native_house_ad.proto
require "protobuf"

module Adgen
  module Proto
    
    struct NativeHouseAd
      include Protobuf::Message
      
      contract_of "proto2" do
        required :publisher_id, :int64, 1
        optional :adsvr_schedule_id, :int64, 2
        optional :adsvr_schedule_name, :string, 3
        repeated :house_ad_creatives, NativeHouseAdCreative, 4
      end
    end
    
    struct NativeHouseAdArray
      include Protobuf::Message
      
      contract_of "proto2" do
        repeated :array, NativeHouseAd, 1
      end
    end
    end
  end
