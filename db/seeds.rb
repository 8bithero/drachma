srand(42)
puts "--------------------------------------------"
puts "             SEEDING DATABASE"
puts "--------------------------------------------"
puts ""
# --------------------------------------------
# USER DATA
# --------------------------------------------
USERS_DATA = [
  {
    email: "homer@springfield.com",
    first_name: "Homer",
    last_name: "Simpson",
    months_back: 6
  },
  {
    email: "marge@springfield.com",
    first_name: "Marge",
    last_name: "Simpson",
    months_back: 3
  }
].freeze

# --------------------------------------------
# LINE ITEM TEMPLATES
# --------------------------------------------
HOMER_INCOME = [
  { item_type: "income", category: "Salary", amount_cents: 430_000, description: "Nuclear Plant Salary" },
  { item_type: "income", category: "Overtime", amount_cents: -> { rand(20_000..80_000) }, description: "Weekend overtime" }
].freeze

HOMER_EXPENDITURES = [
  { item_type: "expenditure", category: "Mortgage", amount_cents: 180_000, description: "Monthly mortgage payment" },
  { item_type: "expenditure", category: "Utilities", amount_cents: -> { rand(15_000..30_000) }, description: "Electric, gas, water" },
  { item_type: "expenditure", category: "Groceries", amount_cents: -> { rand(40_000..80_000) }, description: "Food shopping" },
  { item_type: "expenditure", category: "Car Payment", amount_cents: 45_000, description: "Car loan payment" },
  { item_type: "expenditure", category: "Insurance", amount_cents: 28_000, description: "Home and car insurance" },
  { item_type: "expenditure", category: "Entertainment", amount_cents: -> { rand(10_000..50_000) }, description: "Movies, dining out" },
  { item_type: "expenditure", category: "Beer", amount_cents: -> { rand(8_000..20_000) }, description: "Duff beer and Moe's" }
].freeze

HOMER_OPTIONAL_EXPENDITURES = [
  {
    probability: 0.3,
    item: { item_type: "expenditure", category: "Medical", amount_cents: -> { rand(20_000..100_000) }, description: "Doctor visits, prescriptions" }
  },
  {
    probability: 0.4,
    item: { item_type: "expenditure", category: "Home Improvement", amount_cents: -> { rand(30_000..150_000) }, description: "House repairs and improvements" }
  }
].freeze

MARGE_INCOME = [
  { item_type: "income", category: "Part-time Job", amount_cents: -> { rand(120_000..180_000) }, description: "Retail job" },
  { item_type: "income", category: "Freelance", amount_cents: -> { rand(30_000..70_000) }, description: "Hair styling" }
].freeze

MARGE_EXPENDITURES = [
  { item_type: "expenditure", category: "Groceries", amount_cents: -> { rand(30_000..50_000) }, description: "Family groceries" },
  { item_type: "expenditure", category: "Childcare", amount_cents: 80_000, description: "Maggie's daycare" },
  { item_type: "expenditure", category: "Clothing", amount_cents: -> { rand(10_000..30_000) }, description: "Family clothing" },
  { item_type: "expenditure", category: "Personal Care", amount_cents: -> { rand(5_000..15_000) }, description: "Hair, beauty products" },
  { item_type: "expenditure", category: "Transportation", amount_cents: -> { rand(20_000..40_000) }, description: "Gas, car maintenance" }
].freeze

# --------------------------------------------
# HELPER METHODS
# --------------------------------------------
def create_user(user_data)
  User.find_or_create_by!(email: user_data[:email]) do |user|
    user.first_name = user_data[:first_name]
    user.last_name = user_data[:last_name]
    user.password = 'password123'
    user.password_confirmation = 'password123'
  end
end

def resolve_amount(amount_value)
  amount_value.is_a?(Proc) ? amount_value.call : amount_value
end

def create_line_items(statement, items)
  created_count = 0
  items.each do |item_data|
    line_item = statement.line_items.where(
      category: item_data[:category]
    ).first_or_initialize

    was_new = line_item.new_record?
    line_item.item_type = item_data[:item_type]
    line_item.amount_cents = resolve_amount(item_data[:amount_cents])
    line_item.description = item_data[:description]
    line_item.save!

    created_count += 1 if was_new
  end
  created_count
end

def get_line_items_for_user(user_email)
  case user_email
  when "homer@springfield.com"
    base_items = HOMER_INCOME + HOMER_EXPENDITURES
    optional_items = HOMER_OPTIONAL_EXPENDITURES.filter_map do |optional|
      optional[:item] if rand < optional[:probability]
    end
    base_items + optional_items
  when "marge@springfield.com"
    MARGE_INCOME + MARGE_EXPENDITURES
  else
    []
  end
end

def create_statements_for_user(user, months_back)
  months_back.downto(1) do |months_ago|
    month = months_ago.months.ago.strftime("%Y-%m")

    statement = user.statements.find_or_create_by!(slug: month) do |stmt|
      stmt.name = months_ago.months.ago.strftime("%B %Y")
    end

    line_items = get_line_items_for_user(user.email)
    created_count = create_line_items(statement, line_items)

    puts "Created statement for #{user.first_name} - #{statement.name} (#{statement.line_items_count} line_items)"
  end
end

# --------------------------------------------
# SEED EXECUTION
# --------------------------------------------
USERS_DATA.each do |user_data|
  user = create_user(user_data)
  create_statements_for_user(user, user_data[:months_back])
end

puts ""
puts ""
puts "--------------------------------------------"
puts "             SEEDING COMPLETE"
puts "--------------------------------------------"
puts ""
puts ""
puts "Users: #{User.count}"
puts "Statements: #{Statement.count}"
puts "Line Items: #{LineItem.count}"
puts ""
puts "--------------------------------------------"
puts ""
puts "Login credentials:"
puts "   Email: homer@springfield.com"
puts "   Email: marge@springfield.com"
puts "   Password: password123"
