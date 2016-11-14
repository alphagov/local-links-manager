class CreateTierAndServiceTier < ActiveRecord::Migration[5.0]
  def up
    # create tables
    create_table :tiers do |t|
      t.string :name, null: false, unique: true
      t.timestamps
    end

    create_table :service_tiers do |t|
      t.integer :service_id
      t.integer :tier_id
      t.timestamps
    end

    add_column :local_authorities, :tier_id, :integer, index: true

    # migrate data
    unitary_tier = Tier.create(name: 'unitary')
    district_tier = Tier.create(name: 'district')
    county_tier = Tier.create(name: 'county')

    LocalAuthority.all.each do |la|
      la.tier_id = Tier.find_by(name: la.tier).id
      la.save
    end

    Service.where.not(tier: nil).each do |service|
      case service.tier
      when 'district/unitary'
        ServiceTier.create(service: service, tier: district_tier)
        ServiceTier.create(service: service, tier: unitary_tier)
      when 'county/unitary'
        ServiceTier.create(service: service, tier: county_tier)
        ServiceTier.create(service: service, tier: unitary_tier)
      when 'all'
        ServiceTier.create(service: service, tier: county_tier)
        ServiceTier.create(service: service, tier: unitary_tier)
        ServiceTier.create(service: service, tier: district_tier)
      end
    end

    # delete old data
    remove_column :local_authorities, :tier
    remove_column :services, :tier
  end

  def down
    # add columns
    add_column :local_authorities, :tier, :string
    add_column :services, :tier, :string

    # migrate data
    LocalAuthority.all.each do |la|
      la.tier = Tier.find(la.tier_id).name
      la.save
    end

    Service.enabled.each do |service|
      if service.tiers.count == 3
        service.tier = 'all'
      elsif service.tiers.count == 2
        if service.tiers.map(&:name).include?('district')
          service.tier = 'district/unitary'
        else
          service.tier = 'county/unitary'
        end
      end
      service.save
    end

    # delete old data
    drop_table :tiers
    drop_table :service_tiers
    remove_column :local_authorities, :tier_id
  end
end
