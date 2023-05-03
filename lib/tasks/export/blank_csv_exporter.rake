require "csv"

namespace :export do
  desc "Export blank CSV for new authority"
  task "blank_csv", %i[tier_name] => :environment do |_, args|
    abort "Tier name must be one of: district, county, unitary" unless %w[district county unitary].include?(args.tier_name)

    CSV.open("blank_file_#{args.tier_name}.csv", "wb") do |csv|
      csv << ["Authority Name", "GSS", "Description", "LGSL", "LGIL", "URL", "Supported by GOV.UK", "Status", "New URL"]
      Service.enabled.each do |service|
        next unless service.tiers.include?(args.tier_name)

        service.interactions.each do |interaction|
          description = "#{service.label}: #{interaction.label}"
          csv << ["<authority name here>", "<authority gss here>", description, service.lgsl_code, interaction.lgil_code, "", "TRUE", "missing", "<url for service here>"]
        end
      end
    end
  end
end
