class Tier < ApplicationRecord
  def self.unitary
    find_or_create_by(name: 'unitary')
  end

  def self.district
    find_or_create_by(name: 'district')
  end

  def self.county
    find_or_create_by(name: 'county')
  end
end
