class ServiceTier < ApplicationRecord
  belongs_to :service
  belongs_to :tier
end
