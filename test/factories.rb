# PEOPLE


Factory.define :user do |i|
  i.id 1
  i.name 'John'
  i.email "john@johnson.com"
  i.password 'lettuce'
  i.status User::NORMAL
  i.confirmed_at (DateTime.now - 6.hours)
end

Factory.define :admin, :class => User, :parent => :user do |i|
  i.id 2
  i.name 'Admin'
  i.email 'admin@example.com'
  i.status User::ADMIN
  i.confirmed_at (DateTime.now - 6.hours)
end

Factory.define :trustee, :class => User, :parent => :user do |i|
  i.id 3
  i.name 'Christina'
  i.email 'trustee@lovetax.us'
  i.status User::TRUSTEE
  i.confirmed_at (DateTime.now - 6.hours)
end


Factory.define :fb_user, :class => User do |i|
  i.id 3
  i.name 'Larry S'
  i.facebook_uid 2901636
end

Factory.define :no_login, :class => User do |i|
  i.email nil
  i.password nil
  i.facebook_uid nil
end




Factory.define :tax do |t|
  t.id 1
  t.name 'Portland'
  t.description 'Awesome PDX.'
  t.paypal_email 'nobody@lemonary.com'  
  #t.association :manager_roles, :factory => :trustee
end





Factory.define :pledge do |p|
  p.id 1
  p.amount 5
  p.association :user, :factory => :verified
  p.association :tax, :factory => :tax
  p.status Pledge::ACTIVE
  p.preapproval_key 'toucan'
  p.starts Time.now
  p.ends Time.now + 1.year
end

Factory.define :started, :parent => :pledge do |p|
  p.id 2
  p.status Pledge::INACTIVE
end

Factory.define :paused, :parent => :pledge do |p|
  p.id 3
  p.status Pledge::PAUSED
end

Factory.define :finished, :parent => :pledge do |p|
  p.id 4
  p.status Pledge::FINISHED
end

