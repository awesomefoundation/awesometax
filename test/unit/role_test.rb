require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "new role should validate" do
    role = FactoryGirl.build :role
    assert role.valid?
  end


end
