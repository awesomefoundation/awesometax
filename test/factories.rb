# PEOPLE

FactoryGirl.define do
  factory :user do
    name 'John'
    email 'john@johnson.com'
    password 'lettuce'
    status User::NORMAL
    confirmed_at (DateTime.now - 6.hours)
  end

  factory :admin, :class => User do
    name 'Admin'
    email 'admin@example.com'
    status User::ADMIN
    confirmed_at (DateTime.now - 6.hours)
  end

  factory :trustee, :class => User do
    name 'Christina'
    email 'trustee@lovetax.us'
    password 'lettuce'
    status User::TRUSTEE
    confirmed_at (DateTime.now - 6.hours)
  end

  factory :tax do
    name 'Portland'
    association :owner, :factory => :trustee
    description 'Awesome PDX. We intend to make it even awesomer.'
    goal 200
    paypal_email 'nobody@lemonary.com'
  end

  factory :pledge do
    amount 5
    association :user
    association :tax, :factory => :tax
    status Pledge::ACTIVE
    preapproval_key 'toucan'
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





