## Generated from adgen/native_pure_ad.proto
require "protobuf"

module Adgen
  module Proto
    
    struct NativePureAd
      include Protobuf::Message
      
      contract_of "proto2" do
        optional :publisher_id, :int64, 1
        optional :adsvr_schedule_id, :int64, 2
        optional :adsvr_schedule_name, :string, 3
      end
    end
    
    struct NativePureAdArray
      include Protobuf::Message
      
      contract_of "proto2" do
        repeated :array, NativePureAd, 1
      end
    end
    end
  end
