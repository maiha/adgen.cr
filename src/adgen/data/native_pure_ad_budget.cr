class Adgen::NativePureAdBudget
  JSON.mapping({
    budget_type:                String? , # "click"
    lifetime_budget_impression: Int64?  , # 1
    monthly_budget_impression:  Int64?  , # 1
    daily_budget_impression:    Int64?  , # 1
    lifetime_budget_click:      Int64?  , # 11
    monthly_budget_click:       Int64?  , # 11
    daily_budget_click:         Int64?  , # 111
  })

  def to_pb
    Adgen::Proto::NativePureAdBudget.new(
      budget_type: budget_type,
      lifetime_budget_impression: lifetime_budget_impression,
      monthly_budget_impression: monthly_budget_impression,
      daily_budget_impression: daily_budget_impression,
      lifetime_budget_click: lifetime_budget_click,
      monthly_budget_click: monthly_budget_click,
      daily_budget_click: daily_budget_click,
    )
  end
end
