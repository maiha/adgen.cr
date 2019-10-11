## Generated from adgen/native_pure_ad_budget.proto
require "protobuf"

module Adgen
  module Proto
    
    struct NativePureAdBudget
      include Protobuf::Message
      
      contract_of "proto2" do
        optional :budget_type, :string, 1
        optional :lifetime_budget_impression, :int64, 2
        optional :monthly_budget_impression, :int64, 3
        optional :daily_budget_impression, :int64, 4
        optional :lifetime_budget_click, :int64, 5
        optional :monthly_budget_click, :int64, 6
        optional :daily_budget_click, :int64, 7
      end
    end
    
    struct NativePureAdBudgetArray
      include Protobuf::Message
      
      contract_of "proto2" do
        repeated :array, NativePureAdBudget, 1
      end
    end
    end
  end
