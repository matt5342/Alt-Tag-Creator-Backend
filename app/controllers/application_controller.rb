class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    # before_action :authenticate_user!
    before_action :set_locale
    
    def set_locale
        I18n.locale = current_user.try(:locale) || I18n.default_locale
    end

    private

    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
    helper_method :current_user
end
