class RemoveTrusteeFlag < ActiveRecord::Migration


  def up
    #previously status 3 == trustee and status 4 == disabled

    #users who were previously trustees now have normal status
    User.where(:status => 3).each do |u|
      u.status = 0
      u.save
    end

    #disabled state bumped from status 4 to 3
    User.where(:status => 4).each do |u|
      u.status = 3
      u.save
    end

    #change all existing managers to trustees, except for Christina & Shannon
    Role.where(kind: 1).each do |r|
      unless r.user.name == 'Christina Xu' || r.user.name == 'Shannon Dosemagen'
        #if user is already a trustee destroy the role
        if r.user.trusted_taxes.include?(r.tax)
          r.destroy
        #otherwise transform it into a trustee role
        else
          r.kind = 3
          r.save
        end
      end
    end

    #make all existing supporters also trustees
    Role.where(kind: 2).each do |r|
      unless r.user.trusted_taxes.include?(r.tax)
        Role.create(kind: 3, user_id: r.user_id, tax_id: r.tax_id)
      end
    end

  end

  def down
    User.where(:status => 3).each do |u|
      u.status = 4
      u.save
    end
  end

end