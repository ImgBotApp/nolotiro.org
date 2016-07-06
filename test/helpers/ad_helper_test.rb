# frozen_string_literal: true
require 'test_helper'
require 'support/web_mocking'

class AdHelperTest < ActionView::TestCase
  include WebMocking

  setup { @ad = FactoryGirl.create(:ad, woeid_code: 766_273) }

  test 'should get locations ranking' do
    mocking_yahoo_woeid_info(766_273) do
      actual = AdHelper.get_locations_ranking(1)
      expected = [['Madrid, Madrid, España', 766_273, 1]]
      assert_equal(expected, actual)
    end
  end
end
