require 'test_helper'

User.create( id: 1, name: 'c3po', last_name: 'android')
User.create( id: 2, name: 'r2d2', last_name: 'vedroid')

Comment.create( id: 1, user_id: 1, body: 'beeep' )
Comment.create( id: 2, user_id: 1, body: 'beeep-beeep vedro' )
Comment.create( id: 3, user_id: 2, body: 'ssss' )

class StubberryActiveRecordTest < ActiveSupport::TestCase

  test 'stub_orm_attributes' do
    Comment.include(Stubberry::ActiveRecord)
    assert_not_equal( Comment.find(1).body, 'ola!' )
    Comment.stub_orm_attr(1, body: 'ola!') do
      comments = User.find( 1 ).comments.group_by(&:id)
      assert_equal( comments[1].first.body, 'ola!' )
      assert_not_equal( comments[2].first.body, 'ola!' )
      assert_equal( Comment.find(1).body, 'ola!' )
    end
  end

  test 'stub_orm_method' do
    Comment.include(Stubberry::ActiveRecord)

    assert_not_equal( Comment.find(1).to_s, 'ola!' )

    cmmnts = Comment.stub_orm_method(1, :to_s, -> { 'ola!' }) do
       User.find(1).comments.map(&:to_s)
    end
    assert_equal( cmmnts, ['ola!', 'beeep-beeep vedro'] )
  end
end
