# encoding : utf-8
# frozen_string_literal: true

require 'test_helper'
require 'support/web_mocking'

class AdTest < ActiveSupport::TestCase
  include WebMocking

  setup { @ad = create(:ad) }

  test 'ad requires everything' do
    a = Ad.new
    a.valid?
    assert a.errors[:status].include?('no puede estar en blanco')
    assert a.errors[:body].include?('no puede estar en blanco')
    assert a.errors[:title].include?('no puede estar en blanco')
    assert a.errors[:user_owner].include?('no puede estar en blanco')
    assert a.errors[:type].include?('no puede estar en blanco')
    assert a.errors[:woeid_code].include?('no puede estar en blanco')
  end

  test 'ad validates type' do
    # only is allowed "1 2"
    @ad.type = 1
    assert @ad.valid?
    assert_equal @ad.type, 1
    @ad.type = 2
    assert @ad.valid?
    assert_equal @ad.type, 2
    @ad.type = 3
    refute @ad.valid?
  end

  test 'ad validates status' do
    # only is allowed "1 2 3"
    @ad.status = 1
    assert @ad.valid?
    assert_equal @ad.status, 1
    @ad.status = 2
    assert @ad.valid?
    assert_equal @ad.status, 2
    @ad.status = 3
    assert @ad.valid?
    assert_equal @ad.status, 3
    @ad.status = 4
    refute @ad.valid?
  end

  test 'ad validates maximum length of title' do
    @ad.title = 'a' * 200
    assert_not @ad.save
    assert @ad.errors[:title].include?('es demasiado largo (100 caracteres máximo)')
  end

  test 'ad validates minimum length of title' do
    assert_not @ad.update(title: 'a' * 3)
    assert @ad.errors[:title].include?('es demasiado corto (4 caracteres mínimo)')
  end

  test 'ad title escapes privacy data' do
    text = 'contactar por email example@example.com, por sms 999999999, o whatsapp al 666666666'
    expected_text = 'contactar por email  , por sms  , o   al  '
    @ad.update(title: text)
    assert_equal(@ad.title, expected_text)
  end

  test 'ad body escapes privacy data' do
    text = 'contactar por email example@example.com, por sms 999999999, o whatsapp al 666666666'
    expected_text = 'contactar por email  , por sms  , o   al  '
    @ad.update(body: text)
    assert_equal(@ad.body, expected_text)
  end

  test 'ad validates max length of body' do
    assert_not @ad.update(body: 'a' * 1001)
    assert @ad.errors[:body].include?('es demasiado largo (1000 caracteres máximo)')
  end

  test 'ad validates min length of body' do
    assert_not @ad.update(body: 'a' * 24)
    assert @ad.errors[:body].include?('es demasiado corto (25 caracteres mínimo)')
  end

  test 'ad check slug' do
    assert_equal @ad.slug, 'ordenador-en-vallecas'
  end

  test 'ad check type_string' do
    assert_equal @ad.type_string, 'regalo'
    @ad.update(type: 2)
    assert_equal @ad.type_string, 'busco'
  end

  test 'ad check status_string' do
    assert_equal @ad.status_string, 'disponible'
    @ad.update(status: 2)
    assert_equal @ad.status_string, 'reservado'
    @ad.update(status: 3)
    assert_equal @ad.status_string, 'entregado'
  end

  test 'ad check type_class' do
    assert_equal @ad.type_class, 'give'
    @ad.update(type: 2)
    assert_equal @ad.type_class, 'want'
  end

  test 'ad check status_class' do
    assert_equal @ad.status_class, 'available'
    @ad.update(status: 2)
    assert_equal @ad.status_class, 'booked'
    @ad.update(status: 3)
    assert_equal @ad.status_class, 'delivered'
  end

  test 'ad meta_title for give ads' do
    mocking_yahoo_woeid_info(@ad.woeid_code) do
      @ad.update(type: 1)
      title = 'regalo segunda mano gratis  ordenador en Vallecas Madrid, ' \
              'Madrid, España'
      assert_equal title, @ad.meta_title
    end
  end

  test 'ad meta_title for want ads' do
    skip

    mocking_yahoo_woeid_info(@ad.woeid_code) do
      @ad.update(type: 2)
      title = 'busco ordenador en Vallecas Madrid, Madrid, España'
      assert_equal title, @ad.meta_title
    end
  end

  test 'ad body shoudl store emoji' do
    skip
    body = 'What a nice emoji😀!What a nice emoji😀!What a nice emoji😀!What a nice emoji😀!What a nice emoji😀!'
    @ad.update(body: body)
    assert_equal @ad.body, body
  end

  test 'ad bumping refreshes publication date' do
    @ad.published_at = 1.week.ago
    @ad.bump

    assert_in_delta Time.zone.now.to_i, @ad.published_at.to_i, 1
  end

  test 'ad bumping resets readed count' do
    @ad.readed_count = 100
    @ad.bump

    assert_equal 0, @ad.readed_count
  end

  test 'associated comments are deleted when ad is deleted' do
    create(:comment, ad: @ad)

    assert_difference(-> { Comment.count }, -1) { @ad.destroy }
  end

  test '.from_authors_whitelisting excludes ads from authors blocking user' do
    user = create(:user)
    create(:blocking, blocker: @ad.user, blocked: user)

    assert_equal [create(:ad)], Ad.from_authors_whitelisting(user)
  end

  test '.by_title ignores invalid bytes sequences' do
    assert_equal [], Ad.by_title("Física y Química 3º ESoC3\x93")
  end
end
