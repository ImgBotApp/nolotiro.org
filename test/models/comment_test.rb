# frozen_string_literal: true

require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  test 'comment requires everything' do
    c = Comment.new
    c.valid?

    assert c.errors[:ads_id].include?('no puede estar en blanco')
    assert c.errors[:body].include?('no puede estar en blanco')
    assert c.errors[:user_owner].include?('no puede estar en blanco')
    assert c.errors[:ip].include?('no puede estar en blanco')
  end

  test 'comment title escapes privacy data' do
    text = 'contactar por email example@example.com, o whatsapp al 666666666'
    expected_text = 'contactar por email  , o   al  '
    comment = build(:comment, body: text)

    assert_equal expected_text, comment.filtered_body
  end
end
