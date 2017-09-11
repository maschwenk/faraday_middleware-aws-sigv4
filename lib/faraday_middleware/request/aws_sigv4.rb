require 'aws-sigv4'
require 'faraday_middleware/request/aws_sigv4_util'

class FaradayMiddleware::AwsSigV4 < Faraday::Middleware
  include FaradayMiddleware::AwsSigV4Util

  def initialize(app, options = nil)
    super(app)

    # check options
    build_signer(options)

    @options = options
    @is_net_http_adapter = app.is_a?(Faraday::Adapter::NetHttp)
  end

  def call(env)
    sign!(env)
    @app.call(env)
  end

  private

  def sign!(env)
    signer = build_signer(@options)

    if net_http_adapter?
      normalize_for_net_http!(env)
    end

    request = build_aws_sigv4_request(env)
    signature = signer.sign_request(request)

    env.request_headers.update(signature.headers)
  end

  def build_signer(options)
    Aws::Sigv4::Signer.new(options)
  end

  def build_aws_sigv4_request(env)
    {
      http_method: env.method.to_s,
      url: seahorse_encode_query(env.url),
      headers: env.request_headers,
      body: env.body,
    }
  end

  def net_http_adapter?
    @is_net_http_adapter
  end
end