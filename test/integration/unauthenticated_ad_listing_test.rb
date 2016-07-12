# frozen_string_literal: true
require 'test_helper'
require 'integration/concerns/pagination'
require 'support/web_mocking'

class UnauthenticatedAdListing < ActionDispatch::IntegrationTest
  include WebMocking
  include Pagination

  before do
    create(:ad, :in_mad, title: 'ava_mad', published_at: 1.hour.ago, status: 1)
    create(:ad, :in_bar, title: 'ava_bar', published_at: 2.hours.ago, status: 1)
    create(:ad, :in_mad, title: 'res_mad', status: 2)
    create(:ad, :in_ten, title: 'del_ten', status: 3)

    with_pagination(1) do
      mocking_location_counts { visit root_path }
    end
  end

  it 'lists first page of available ads everywhere in home page' do
    page.assert_selector '.ad_excerpt_list', count: 1, text: 'ava_mad'
  end

  it 'lists second page of available ads everywhere in all ads page' do
    with_pagination(1) do
      mocking_yahoo_woeid_info(753_692) { click_link 'ver más anuncios' }

      page.assert_selector '.ad_excerpt_list', count: 1, text: 'ava_bar'
    end
  end

  it 'lists booked ads everywhere in all ads page' do
    with_pagination(1) do
      mocking_yahoo_woeid_info(753_692) { click_link 'ver más anuncios' }
      mocking_yahoo_woeid_info(766_273) { click_link 'reservado' }

      page.assert_selector '.ad_excerpt_list', count: 1, text: 'res_mad'
    end
  end

  it 'lists booked ads everywhere in all ads page' do
    with_pagination(1) do
      mocking_yahoo_woeid_info(753_692) { click_link 'ver más anuncios' }
      mocking_yahoo_woeid_info(773_692) { click_link 'entregado' }

      page.assert_selector '.ad_excerpt_list', count: 1, text: 'del_ten'
    end
  end

  private

  def mocking_location_counts
    mocking_yahoo_woeid_info(766_273) do
      mocking_yahoo_woeid_info(753_692) do
        mocking_yahoo_woeid_info(773_692) { yield }
      end
    end
  end
end
