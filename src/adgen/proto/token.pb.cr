## Generated from adgen/token.proto
require "protobuf"

module Adgen
  module Proto
    
    struct Token
      include Protobuf::Message
      
      contract_of "proto2" do
        optional :email, :string, 1
        optional :token, :string, 2
        optional :expired_at_str, :string, 3
      end
    end
    
    struct TokenArray
      include Protobuf::Message
      
      contract_of "proto2" do
        repeated :array, Token, 1
      end
    end
    end
  end
