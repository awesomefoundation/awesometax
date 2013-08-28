class RemoveTrusteeFlag < ActiveRecord::Migration
  def up
    User.where(:status => 3).each do |u|
      u.status = 0
      u.save
    end
    User.where(:status => 4).each do |u|
      u.status = 3
      u.save
    end
  end

  def down
    User.where(:status => 3).each do |u|
      u.status = 4
      u.save
    end
  end
end
