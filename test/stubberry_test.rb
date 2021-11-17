require "test_helper"

class StubberryTest < ActiveSupport::TestCase
  extend ::ActiveSupport::Testing::Declarative

  def test_that_it_has_a_version_number
    refute_nil ::Stubberry::VERSION
  end

  test 'Subbery::Object methods available for objects' do
    assert( String.respond_to?(:stub_must) )
    assert( String.respond_to?(:stub_must_all) )
    assert( String.respond_to?(:stub_must_not) )
  end

  test 'stub_must should raise an error whenever method NOT called inside a block' do
    assert_raise( StandardError ) { self.stub_must(:to_s, true) {} }

    assert_nothing_raised { self.stub_must(:to_s, true) { to_s } }
  end

  test 'stub_must_not should raise an error whenever method called inside a block' do
    assert_raise( StandardError ) { self.stub_must_not(:to_s, true) { to_s } }
    assert_nothing_raised { self.stub_must_not(:to_s, true) { } }
  end

  test 'stub_must_all should not raise anything whenever all of stubbed method were called' do
    assert_nothing_raised {
      self.stub_must_all({
          to_s: true,
          is_a?: -> ( klass ) { assert_equal( klass, ::Minitest::Test ) }
        }) do
        to_s
        is_a?( ::Minitest::Test )
      end
    }
  end

  test 'stub_must_all should raise whenever any of stubbed method wasnt called' do
    assert_raise(StandardError) {
      self.stub_must_all({ to_s: true, is_a?: false }) do
        to_s
      end
    }

    begin
      self.stub_must_all({ to_s: true, is_a?: false }) { to_s }
    rescue => e
      assert_equal( e.to_s, "is_a? wasn't called"  )
    end

    begin
      self.stub_must_all({ to_s: true, is_a?: false }) { is_a?(String) }
    rescue => e
      assert_equal( e.to_s, "to_s wasn't called"  )
    end
  end

  test 'stub/must_if_def methods yields if method not defined' do
    flow = []
    String.stub_if_def( :not_a_method, true ) { flow << :stub_if_def }
    String.stub_must_if_def( :not_a_method, true ) { flow << :stub_must_if_def }

    assert_equal(flow, %i[stub_if_def stub_must_if_def])
  end

  test 'stub_if_def acts as usual stub when methpd defined' do
    flow = []
    String.stub_if_def( :to_s, -> { flow << :stub_if_def } ) {  }
    assert_equal(flow, [])
  end

  test 'stub_must_if_def acts as stub_must when method defined' do
    flow = []
    assert_raise(StandardError) do
      String.stub_must_if_def( :to_s, -> { flow << :stub_if_def } ) {}
    end
  end

end
