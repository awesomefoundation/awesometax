# PEOPLE

FactoryGirl.define do
  factory :user do
    name 'John User'
    email 'john@johnson.com'
    password 'lettuce'
    status User::NORMAL
    confirmed_at (DateTime.now - 6.hours)
  end

  factory :admin, :class => User do
    name 'Admin User'
    email 'admin@example.com'
    password 'lettuce'
    status User::ADMIN
    confirmed_at (DateTime.now - 6.hours)
  end

  factory :trustee, :parent => :user do
    after(:create) do |user|
      create(:trustee_role, user: user)
    end
  end

  factory :manager, :parent => :user do
    after(:create) do |user|
      create(:manager_role, user: user)
    end
  end

  factory :role do
    kind Role::FUNDER
    association :user
    association :tax
  end

  factory :manager_role, :parent => :role do
    kind Role::MANAGER
  end

  factory :trustee_role, :parent => :role do
    kind Role::TRUSTEE
  end

  factory :tax do
    name 'Portland'
    association :owner, :factory => :admin
    description 'Awesome PDX. We intend to make it even awesomer.'
    goal 200
    bank_token = Stripe::Token.create(:bank_account => {:country => "US", :routing_number => "110000000", :account_number => "000123456789",},).id
    recipient_id 'rp_102lW02HxIFZsDb1Jy8tD5aK'
  end

  factory :pledge do
    amount 5
    association :user
    association :tax, :factory => :tax
    status Pledge::ACTIVE
    stripe_token 'tok_102lVw2HxIFZsDb1g5Mlt8QH'
    starts Time.now
    ends Time.now + 1.year
  end

  factory :started, :parent => :pledge do
    status Pledge::INACTIVE
  end

  factory :paused, :parent => :pledge do
    status Pledge::PAUSED
  end

  factory :finished, :parent => :pledge do
    status Pledge::FINISHED
  end

end

# FactoryGirl.define :no_login, :class => User do |i|
#   i.email nil
#   i.password nil
#   i.facebook_uid nil
# end





