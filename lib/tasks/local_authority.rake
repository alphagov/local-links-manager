namespace :local_authority do
  desc "Create a new local authority"
  task :create, %i[gss name snac slug tier_id country_name] => [:environment] do |_, args|
    # TODO: write this code in a lib/ class and call it from here?
    la = LocalAuthority.new
    la.gss = args.gss
    la.name = args.name
    la.snac = args.snac
    la.slug = args.slug
    la.tier_id = args.tier_id
    la.country_name = args.country_name

    if la.valid?
      la.save!
      summariser.increment_created_record_count
      # TODO we also need to deal with parent/child/orphaned upper/lower tiers. See removed commit.
      puts "Success!"
    else
      puts "Could not save new local authority"
    end
  end

  desc "Update an existing local authority"
  task :update, %i[...] => [:environment] do |_, args|
    # TODO
  end

  desc "Redirect one local authority to another."
  task :redirect, %i[from to] => [:environment] do |_, args|
    old_local_authority = LocalAuthority.find_by!(slug: args.from)
    new_local_authority = LocalAuthority.find_by!(slug: args.to)
    old_local_authority.redirect(to: new_local_authority)
  end

  desc "Set local authority homepage URL"
  task :update_homepage, %i[slug new_url] => :environment do |_, args|
    local_authority = LocalAuthority.find_by!(slug: args.slug)
    local_authority.homepage_url = args.new_url
    local_authority.save!
  end
end
