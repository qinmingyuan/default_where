require 'helper'
require 'models/user'

class DefaultWhereTest < ActiveSupport::TestCase

  test 'truth' do
    assert_kind_of Module, DefaultWhere
  end

  test 'basic' do
    create :user
    params = { id: 1, uid: 2, name: 3 }
    options = { signs: 'name' }

    count = User.default_where(name: 'qinmingyuan').count
    assert_equal 1, count
  end

end
