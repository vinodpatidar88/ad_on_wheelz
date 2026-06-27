# Seed initial AdminUser
AdminUser.find_or_create_by!(email: 'admin@example.com') do |admin|
  admin.password = 'password123'
  admin.password_confirmation = 'password123'
end
puts "Seeded AdminUser: admin@example.com / password123"

# Seed Categories
automotive = Category.find_or_create_by!(name: 'Automotive') do |c|
  c.description = 'Campaigns related to cars, driving, and transit media.'
end

retail = Category.find_or_create_by!(name: 'Retail') do |c|
  c.description = 'Campaigns for shopping, fashion, and retail rewards.'
end

# Seed SubCategories
cab_ads = SubCategory.find_or_create_by!(name: 'Cab Advertising', category: automotive) do |s|
  s.description = 'Visual wraps and in-car advertising for app-based cabs.'
end

gadgets = SubCategory.find_or_create_by!(name: 'Mobile Gadgets', category: retail) do |s|
  s.description = 'Smartphones, audio, and personal electronic accessories.'
end

# Seed Campaigns
summer_rewards = Campaign.find_or_create_by!(name: 'AdOnWheels Launch & Summer Rewards') do |c|
  c.sub_category = cab_ads
  c.description = 'Scan QR codes on transit cabs to unlock gifts, cash prizes, and trips!'
  c.start_date = 1.day.ago
  c.end_date = 3.months.from_now
  c.qr_token = 'ADONWHEELS01'
end
puts "Seeded Campaign: 'AdOnWheels Launch & Summer Rewards' with QR Token: ADONWHEELS01"

# Seed Rewards for Campaign
# 1. Gift
Reward.find_or_create_by!(name: 'Premium Leather Keyring', campaign: summer_rewards) do |r|
  r.reward_type = 'gift'
  r.description = 'Handcrafted genuine leather keyring with embossed silver logo.'
  r.stock = 100
end

# 2. Price/Prize (called price as requested in enum)
Reward.find_or_create_by!(name: '$50 Fuel Voucher', campaign: summer_rewards) do |r|
  r.reward_type = 'price'
  r.description = 'A digital gift card redeemable for $50 worth of fuel at partner stations.'
  r.stock = 50
end

# 3. Trip
Reward.find_or_create_by!(name: 'Weekend Getaway for Two', campaign: summer_rewards) do |r|
  r.reward_type = 'trip'
  r.description = 'All-expenses-paid weekend stay at the Grand Canyon Resort, including travel.'
  r.stock = 5
end

puts "Seeded Rewards for 'AdOnWheels Launch & Summer Rewards'"
