# frozen_string_literal: true

module MultiLingualizable
  def self.included(base)
    base.extend ClassMethods

    base.class_eval { before_action :set_locale }
  end

  module ClassMethods
    def default_url_options(_options = {})
      { locale: I18n.locale }
    end
  end

  def set_locale
    I18n.locale =
      params_locale || cookie_locale || browser_locale || default_locale
  end

  def params_locale
    params[:locale].presence
  end

  def cookie_locale
    locale = cookies.permanent[:locale]
    # @note This validation is necessary because, although we validate the
    # locale before saving the cookie, we've deprecated nl & eu locales so some
    # cookies already set are no longer valid. Once we readd these locales we
    # can remove this.
    return unless valid_locale?(locale)

    locale
  end

  def browser_locale
    http_accept_language.compatible_language_from(I18n.available_locales)
  end

  def default_locale
    I18n.default_locale
  end

  def valid_locale?(locale)
    return false unless locale.present?

    I18n.available_locales.include?(locale.to_sym)
  end
end
