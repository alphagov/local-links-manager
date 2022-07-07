RSpec.describe "find local authority", type: :request do
  context "for councils that have a parent authority" do
    let(:parent_local_authority) do
      create(
        :county_council,
        name: "Rochester",
        slug: "rochester",
        homepage_url: "http://rochester.example.com",
        country_name: "England",
        local_custodian_code: "2265",
      )
    end
    let!(:local_authority) do
      create(
        :district_council,
        name: "Blackburn",
        slug: "blackburn",
        homepage_url: "http://blackburn.example.com",
        country_name: "England",
        parent_local_authority: parent_local_authority,
        local_custodian_code: "2372",
      )
    end

    let(:expected_response) do
      {
        "local_authorities" => [
          {
            "name" => "Blackburn",
            "homepage_url" => "http://blackburn.example.com",
            "country_name" => "England",
            "tier" => "district",
          },
          {
            "name" => "Rochester",
            "homepage_url" => "http://rochester.example.com",
            "country_name" => "England",
            "tier" => "county",
          },
        ],
      }
    end

    it "returns details of the child and parent in the api response when searching by slug" do
      get "/api/local-authority?authority_slug=blackburn"

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to eq(expected_response)
    end

    it "returns details of the child and parent in the api response when searching by local custodian code" do
      get "/api/local-authority?local_custodian_code=2372"

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to eq(expected_response)
    end
  end

  context "for councils that do not have a parent authority" do
    let!(:local_authority) do
      create(
        :unitary_council,
        name: "Blackburn",
        slug: "blackburn",
        homepage_url: "http://blackburn.example.com",
        country_name: "England",
        local_custodian_code: "2372",
      )
    end

    let(:expected_response) do
      {
        "local_authorities" => [
          {
            "name" => "Blackburn",
            "homepage_url" => "http://blackburn.example.com",
            "country_name" => "England",
            "tier" => "unitary",
          },
        ],
      }
    end

    it "returns details of the council in the api response when searching by slug" do
      get "/api/local-authority?authority_slug=blackburn"

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to eq(expected_response)
    end

    it "returns details of the council in the api response when searching by local custodian code" do
      get "/api/local-authority?local_custodian_code=2372"

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to eq(expected_response)
    end
  end

  context "for requests with missing parameters" do
    it "returns a 400 status" do
      get "/api/local-authority"

      expect(response.status).to eq(400)
      expect(JSON.parse(response.body)).to eq({})
    end
  end

  context "for requests with parameters that do not refer to data" do
    it "returns a 404 status when an invalid slug is used" do
      get "/api/local-authority?authority_slug=foobar"

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)).to eq({})
    end

    it "returns a 404 status when an invalid local custodian code is used" do
      get "/api/local-authority?local_custodian_code=9999999"

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)).to eq({})
    end
  end
end
