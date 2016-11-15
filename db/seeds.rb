%w[ unitary district county ].each { |tier| Tier.find_or_create_by(name: tier) }
