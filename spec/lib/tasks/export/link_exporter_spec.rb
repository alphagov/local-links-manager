require "rails_helper"

RSpec.describe "Export tasks" do
  describe "export:links:s3" do
    it "should write the links to S3" do
      service = create(:service, :all_tiers, lgsl_code: 1)
      service_interaction = create(:service_interaction, service:)
      link = create(:link, service_interaction:)

      la = LocalAuthority.last
      interaction = service_interaction.interaction
      expected_body = <<~EXPECTED_BODY_TEXT
        Authority Name,GSS,Description,LGSL,LGIL,URL,Supported by GOV.UK,Not Provided by Authority
        #{la.name},#{la.gss},#{service.label}: #{interaction.label},#{service.lgsl_code},#{interaction.lgil_code},#{link.url},true,false
      EXPECTED_BODY_TEXT

      s3 = double
      allow(Aws::S3::Client).to receive(:new).and_return(s3)
      expect(s3).to receive(:put_object).with({
        body: expected_body,
        bucket: nil,
        key: "data/local-links-manager/links_to_services_provided_by_local_authorities.csv",
      })

      Rake::Task["export:links:s3"].execute
    end
  end
end
