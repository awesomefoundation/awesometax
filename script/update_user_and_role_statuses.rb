#remove trustee status
#previously status 3 == trustee and status 4 == disabled

#users who were previously trustees (3) now have normal status (0)
User.update_all("status=0", "status=3")

#disabled state bumped from status 4 to 3
User.update_all("status=3", "status=4")

#change all existing managers to trustees, except for Christina & Shannon
Role.where(kind: Role::MANAGER).each do |r|
  unless r.user.name == 'Christina Xu' || r.user.name == 'Shannon Dosemagen'
    r.kind = Role::TRUSTEE
    r.save
  end
end

#make all existing supporters also trustees
Role.where(kind: Role::FUNDER).each do |r|
  unless r.user.trusted_taxes.include?(r.tax)
    Role.create(kind: Role::TRUSTEE, user_id: r.user_id, tax_id: r.tax_id)
  end
end