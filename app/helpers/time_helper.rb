# frozen_string_literal: true

module TimeHelper
  def time_ago_in_words(time)
    content_tag(:abbr, title: time) do
      t('time_ago_in_words', time: distance_of_time_in_words_to_now(time))
    end
  end

  def published_ago_by(time, user)
    content_tag(:span, class: 'ad_date') do
      t('nlt.published_ago_by_html',
        time: time_ago_in_words(time),
        user: link_to(user.username, profile_path(user)))
    end
  end
end
