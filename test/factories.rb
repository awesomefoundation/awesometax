# PEOPLE

FactoryGirl.define do
  factory :user do
    id 1
    name 'John'
    email 'john@johnson.com'
    password 'lettuce'
    status User::NORMAL
    confirmed_at (DateTime.now - 6.hours)
  end

  factory :admin, :class => User do
    id 2
    name 'Admin'
    email 'admin@example.com'
    status User::ADMIN
    confirmed_at (DateTime.now - 6.hours)
  end

  factory :trustee, :class => User do
    id 3
    name 'Christina'
    email 'trustee@lovetax.us'
    status User::TRUSTEE
    confirmed_at (DateTime.now - 6.hours)
  end

  factory :tax do
    id 1
    name 'Portland'
    description 'Awesome PDX.'
    paypal_email 'nobody@lemonary.com'
  end

  factory :pledge do
    id 1
    amount 5
    association :user, :factory => :verified
    association :tax, :factory => :tax
    status Pledge::ACTIVE
    preapproval_key 'toucan'
    starts Time.now
    ends Time.now + 1.year
  end

  factory :started, :parent => :pledge do
    id 2
    status Pledge::INACTIVE
  end

  factory :paused, :parent => :pledge do
    id 3
    status Pledge::PAUSED
  end

  factory :finished, :parent => :pledge do
    id 4
    status Pledge::FINISHED
  end

end


# FactoryGirl.define :fb_user, :class => User do |i|
#   i.id 3
#   i.name 'Larry S'
#   i.facebook_uid 2901636
# end

# FactoryGirl.define :no_login, :class => User do |i|
#   i.email nil
#   i.password nil
#   i.facebook_uid nil
# end





