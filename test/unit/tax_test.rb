require 'test_helper'

class TaxTest < ActiveSupport::TestCase

  test "new tax should validate" do
    tax = FactoryGirl.build :tax
    assert tax.valid?
  end

  # test "incomplete taxes should fail" do

  # end

  # stopping it

end
