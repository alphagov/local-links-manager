require 'rails_helper'

RSpec.describe "link path", type: :request do
  context "for a request with authority slug, lgsl and lgil params" do
    let(:local_authority) {
      FactoryGirl.create(:local_authority,
                         name: 'Blackburn',
                         slug: 'blackburn',
                         homepage_url: "http://blackburn.example.com",
                         snac: "00AG")
    }
    let(:service) { FactoryGirl.create(:service, label: 'abandoned-shopping-trolleys', lgsl_code: 2) }
    let(:interaction) { FactoryGirl.create(:interaction, label: 'report', lgil_code: 4) }
    let(:service_interaction) { FactoryGirl.create(:service_interaction, service: service, interaction: interaction) }
    let!(:link) { FactoryGirl.create(:link, local_authority: local_authority, service_interaction: service_interaction) }

    let(:expected_response) {
      {
        "local_authority" => {
          "name" => "Blackburn",
          "snac" => "00AG",
          "tier" => "unitary",
          "homepage_url" => "http://blackburn.example.com",
        },
        "local_interaction" => {
          "lgsl_code" => 2,
          "lgil_code" => 4,
          "url" => "http://blackburn.example.com/abandoned-shopping-trolleys/report",
        }
      }
    }
    let(:expected_response_with_no_link) {
      {
        "local_authority" => {
          "name" => "Blackburn",
          "snac" => "00AG",
          "tier" => "unitary",
          "homepage_url" => "http://blackburn.example.com",
        },
      }
    }

    it "responds with LocalAuthority and Link details" do
      get "/api/link?authority_slug=blackburn&lgsl=2&lgil=4"

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to eq(expected_response)
    end

    it "responds without link details if Link not present for LGIL" do
      interaction = FactoryGirl.create(:interaction, lgil_code: 5)
      FactoryGirl.create(:service_interaction, service: service, interaction: interaction)
      get "/api/link?authority_slug=blackburn&lgsl=2&lgil=5"

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to eq(expected_response_with_no_link)
    end

    it "responds with 404 and {} for unsupported local_authority" do
      get "/api/link?authority_slug=hogwarts&lgsl=2&lgil=4"

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)).to eq({})
    end

    it "responds with 404 and {} for unsupported lgsl" do
      get "/api/link?authority_slug=blackburn&lgsl=99&lgil=4"

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)).to eq({})
    end

    it "responds without link details for unsupported lgsl and lgil combination" do
      link.destroy
      service_interaction.destroy

      get "/api/link?authority_slug=blackburn&lgsl=2&lgil=4"

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to eq(expected_response_with_no_link)
    end
  end

  context "for a request with authority slug and lgsl params" do
    let!(:local_authority) {
      FactoryGirl.create(:local_authority,
                         name: 'Blackburn',
                         slug: 'blackburn',
                         homepage_url: "http://blackburn.gov.uk",
                         snac: "00AG")
    }
    let!(:service) { FactoryGirl.create(:service, label: 'abandoned-shopping-trolleys', lgsl_code: 2) }

    context "when LGILs exist" do
      it "responds with Link details for the lowest LGIL" do
        expected_response = {
          "local_authority" => {
            "name" => "Blackburn",
            "snac" => "00AG",
            "tier" => "unitary",
            "homepage_url" => "http://blackburn.gov.uk",
          },
          "local_interaction" => {
            "lgsl_code" => 2,
            "lgil_code" => 1,
            "url" => "http://blackburn.example.com/abandoned-shopping-trolleys/report",
          }
        }

        interaction_1 = FactoryGirl.create(:interaction, label: 'report', lgil_code: 1)
        interaction_2 = FactoryGirl.create(:interaction, label: 'appeal', lgil_code: 2)
        service_interaction_1 = FactoryGirl.create(:service_interaction, service: service, interaction: interaction_1)
        service_interaction_2 = FactoryGirl.create(:service_interaction, service: service, interaction: interaction_2)
        FactoryGirl.create(:link, local_authority: local_authority, service_interaction: service_interaction_1)
        FactoryGirl.create(:link, local_authority: local_authority, service_interaction: service_interaction_2)

        get "/api/link?authority_slug=blackburn&lgsl=2"

        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(expected_response)
      end

      it "does not respond with LGIL 8 even if it is the lowest" do
        expected_response = {
          "local_authority" => {
            "name" => "Blackburn",
            "snac" => "00AG",
            "tier" => "unitary",
            "homepage_url" => "http://blackburn.gov.uk",
          },
          "local_interaction" => {
            "lgsl_code" => 2,
            "lgil_code" => 9,
            "url" => "http://blackburn.example.com/abandoned-shopping-trolleys/regulation",
          }
        }

        interaction_1 = FactoryGirl.create(:interaction, label: 'providing_information', lgil_code: 8)
        interaction_2 = FactoryGirl.create(:interaction, label: 'regulation', lgil_code: 9)
        service_interaction_1 = FactoryGirl.create(:service_interaction, service: service, interaction: interaction_1)
        service_interaction_2 = FactoryGirl.create(:service_interaction, service: service, interaction: interaction_2)
        FactoryGirl.create(:link, local_authority: local_authority, service_interaction: service_interaction_1)
        FactoryGirl.create(:link, local_authority: local_authority, service_interaction: service_interaction_2)

        get "/api/link?authority_slug=blackburn&lgsl=2"

        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(expected_response)
      end
    end

    context "the only LGIL that exists is LGIL 8" do
      it "responds with Link details for the LGIL 8" do
        expected_response = {
          "local_authority" => {
            "name" => "Blackburn",
            "snac" => "00AG",
            "tier" => "unitary",
            "homepage_url" => "http://blackburn.gov.uk",
          },
          "local_interaction" => {
            "lgsl_code" => 2,
            "lgil_code" => 8,
            "url" => "http://blackburn.example.com/abandoned-shopping-trolleys/providing_information",
          }
        }

        interaction = FactoryGirl.create(:interaction, label: 'providing_information', lgil_code: 8)
        service_interaction = FactoryGirl.create(:service_interaction, service: service, interaction: interaction)
        FactoryGirl.create(:link, local_authority: local_authority, service_interaction: service_interaction)

        get "/api/link?authority_slug=blackburn&lgsl=2"

        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(expected_response)
      end
    end

    context "no LGIL links exist" do
      it "responds with no link details" do
        expected_response = {
          "local_authority" => {
            "name" => "Blackburn",
            "snac" => "00AG",
            "tier" => "unitary",
            "homepage_url" => "http://blackburn.gov.uk",
          },
        }
        get "/api/link?authority_slug=blackburn&lgsl=2"

        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(expected_response)
      end
    end

    it "responds with 404 and {} for unsupported local_authority" do
      get "/api/link?authority_slug=hogwarts&lgsl=2"

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)).to eq({})
    end

    it "responds with 404 and {} for unsupported lgsl" do
      get "/api/link?authority_slug=blackburn&lgsl=99"

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)).to eq({})
    end
  end

  context "for a request with missing mandatory query parameters" do
    it "responds with 400 and {} for missing authority_slug param" do
      get "/api/link?lgsl=2"

      expect(response.status).to eq(400)
      expect(JSON.parse(response.body)).to eq({})
    end

    it "responds with 400 and {} for missing lgsl param" do
      get "/api/link?authority_slug=blackburn"

      expect(response.status).to eq(400)
      expect(JSON.parse(response.body)).to eq({})
    end
  end
end
