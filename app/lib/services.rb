require "redis"
require "gds_api/publishing_api"

module Services
  def self.icinga_check(service_desc, code, message)
    if Rails.env.production?
      `/usr/local/bin/notify_passive_check #{service_desc.shellescape} #{code.shellescape} #{message.shellescape}`
    end
  end
end
