module Beacnox
  class BaseController < ActionController::Base
    include Beacnox::Concerns::CsvExportable
    layout "beacnox/layouts/beacnox"

    before_action :verify_access

    if Beacnox.http_basic_authentication_enabled
      http_basic_authenticate_with \
        name: Beacnox.http_basic_authentication_user_name,
        password: Beacnox.http_basic_authentication_password
    end

    private

    def verify_access
      result = Beacnox.verify_access_proc.call(self)
      redirect_to("/", error: "Access Denied", status: 401) unless result
    end
  end
end
