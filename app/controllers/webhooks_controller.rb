require "gds_api/link_checker_api"
require "local-links-manager/check_links/link_status_updater"

class WebhooksController < ApplicationController
  skip_before_action :require_signin_permission!
  skip_before_action :verify_authenticity_token
  before_action :verify_signature

  def link_check_callback
    LocalLinksManager::CheckLinks::LinkStatusUpdater.new.call(
      GdsApi::LinkCheckerApi::BatchReport.new(
        params.to_unsafe_hash
      )
    )
  end

private

  def verify_signature
    return unless Rails.application.secrets.link_checker_api_secret_token

    given_signature = request.headers["X-LinkCheckerApi-Signature"]
    return head :bad_request unless given_signature

    body = request.raw_post
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), webhook_secret_token, body)
    head :bad_request unless Rack::Utils.secure_compare(signature, given_signature)
  end

  def webhook_secret_token
    Rails.application.secrets.link_checker_api_secret_token
  end
end
