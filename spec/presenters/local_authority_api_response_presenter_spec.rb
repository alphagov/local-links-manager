describe LocalAuthorityApiResponsePresenter do
  describe "#present" do
    context "when the local authority has a parent" do
      let(:parent_local_authority) { build(:county_council) }
      let(:authority) { build(:district_council, parent_local_authority:) }
      let(:presenter) { described_class.new(authority) }
      let(:expected_response) do
        {
          "local_authorities" => [
            {
              "name" => authority.name,
              "homepage_url" => authority.homepage_url,
              "country_name" => authority.country_name,
              "tier" => "district",
              "slug" => authority.slug,
              "snac" => authority.snac,
              "gss" => authority.gss,
            },
            {
              "name" => parent_local_authority.name,
              "homepage_url" => parent_local_authority.homepage_url,
              "country_name" => parent_local_authority.country_name,
              "tier" => "county",
              "slug" => parent_local_authority.slug,
              "snac" => parent_local_authority.snac,
              "gss" => parent_local_authority.gss,
            },
          ],
        }
      end
      it "returns a json with the authority's details and its parent authority details" do
        expect(presenter.present).to eq(expected_response)
      end
    end

    context "when local authority does not have a parent" do
      let(:authority) { build(:unitary_council) }
      let(:presenter) { described_class.new(authority) }
      let(:expected_response) do
        {
          "local_authorities" => [
            {
              "name" => authority.name,
              "homepage_url" => authority.homepage_url,
              "country_name" => authority.country_name,
              "tier" => "unitary",
              "slug" => authority.slug,
              "snac" => authority.snac,
              "gss" => authority.gss,
            },
          ],
        }
      end

      it "returns a json response with unitary local authority details" do
        expect(presenter.present).to eq(expected_response)
      end
    end
  end
end
