require "csv"

namespace :export do
    desc "Export blank CSV for new authority"
    task "blank_csv", %i[authority_name snac gss] => :environment do |_, args|
        CSV.open("blank_file.csv", "wb") do |csv|
            csv << ["Authority Name", "SNAC", "GSS", "Description", "LGSL", "LGIL", "URL", "Supported by GOV.UK", "Status", "New URL"]
            Service.enabled.each do |service|
                service.interactions.each do |interaction|
                    description = "#{service.label}: #{interaction.label}"
                    csv << [args.authority_name, args.snac, args.gss, description, service.lgsl_code, interaction.lgil_code, "", "TRUE", "missing", "" ]
                end
            end
        end
    end
end
