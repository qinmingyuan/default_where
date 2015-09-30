require 'test_helper'

class DefaultWhereTest < ActiveSupport::TestCase

  test "truth" do
    assert_kind_of Module, DefaultWhere
  end

  test "" do
    params = { id: 1, uid: 2, name: 3 }
    options = { signs: 'name' }


  end

end
