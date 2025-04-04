require "csv"
require "aws-sdk-s3"

namespace :export do
  namespace :links do
    desc "Generate links status to CSV and upload to S3"
    task "status": :environment do
      filename = "links_with_local_authority_service.csv"

      bucket = ENV["AWS_S3_ASSET_BUCKET_NAME"]
      key = "data/local-links-manager/#{filename}"

      s3 = Aws::S3::Client.new

      StringIO.open do |body|
        output = CSV.generate do |csv|
          csv << ["Link", "Local Authority", "Service", "Status", "Problem Summary"]
          Link.joins(:local_authority, :service)
            .select("links.url AS link_url", "local_authorities.name AS local_authority_name", "services.label AS service_name", "links.status AS link_status", "links.problem_summary AS link_problem_summary")
            .each do |link|
              csv << [link.link_url, link.local_authority_name, link.service_name, link.link_status, link.link_problem_summary]
            end
        end
        body.write(output)

        s3.put_object({ body: body.string, bucket:, key: })
      end
    end
  end
end
