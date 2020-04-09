SERVICE_MAPPINGS = {
    "shielding"    => { lgsl: 1287, lgil: 8 },
    "vulnerable"   => { lgsl: 1287, lgil: 6 },
    "volunteering" => { lgsl: 1113, lgil: 8 },
}.freeze

namespace :import do
  desc "Imports COVID-19 shielding links from TheyHelpYou"
  task covid19_shielding: :environment do
    SERVICE_MAPPINGS.each do |type, codes|
      puts "Fetching mappings for type #{type}, LGSL=#{codes[:lgsl]} LGIL=#{codes[:lgil]}"
      service_interaction = ServiceInteraction.find_or_create_by(
        service: Service.find_by(lgsl_code: codes[:lgsl]),
        interaction: Interaction.find_by(lgil_code: codes[:lgil]),
      )

      response = Net::HTTP.get_response(URI.parse("https://www.theyhelpyou.co.uk/api/export-local-links-manager?type=#{type}"))
      unless response.code_type == Net::HTTPOK
        raise DownloadError, "Error downloading JSON in #{self.class}"
      end

      data = JSON.parse(response.body)
      puts "Got #{data.count} links"
      data.each do |gss, url|
        link = Link.find_or_initialize_by(
          local_authority: LocalAuthority.find_by(gss: gss),
            service_interaction: service_interaction,
        )
        link.url = url
        link.save!
      end
      puts "Done"
    end
  end
end
