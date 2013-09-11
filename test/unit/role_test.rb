require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  test "new role should validate" do
    role = FactoryGirl.create :role
    assert role.valid?
  end

  test "user cannot be manager and trustee" do
    user = FactoryGirl.create(:user)
    tax = FactoryGirl.create(:tax)
    manager_role = Role.create(kind: Role::MANAGER, user_id: user.id, tax_id: tax.id)
    trustee_role = Role.new(kind: Role::TRUSTEE, user_id: user.id, tax_id: tax.id)
    assert !trustee_role.save, "user is both manager and trustee"
  end

end