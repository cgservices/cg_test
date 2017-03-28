class TestController < ApplicationController
  def index

    @http_host = request.env['HTTP_HOST']
    @http_user_agent = request.env['HTTP_USER_AGENT']
    @server_name = request.env['SERVER_NAME']
    @server_port = request.env['SERVER_PORT']
    @remote_addr = request.env['REMOTE_ADDR']
    @http_x_fowarded_for = request.env['HTTP_X_FORWARDED_FOR']

  end
end
