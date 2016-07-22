require 'rails_helper'

RSpec.describe InteractionsController, type: :controller do

  describe "GET #index" do

    before do
      @local_authority = FactoryGirl.create(:local_authority, name: 'Angus')
      @service = FactoryGirl.create(:service, label: 'Service 1', lgsl_code: 1)
      @interaction = FactoryGirl.create(:interaction, label: 'Interaction 1', lgil_code: 3)
    end

    it "returns http success" do
      login_as_stub_user
      get :index, local_authority_slug: @local_authority.slug, service_slug: @service.slug
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do

    before do
      @local_authority = FactoryGirl.create(:local_authority, name: 'Blackburn')
      @service = FactoryGirl.create(:service, label: 'Service 2', lgsl_code: 2)
      @interaction = FactoryGirl.create(:interaction, label: 'Interaction 4', lgil_code: 4)
      @service_interaction = FactoryGirl.create(:service_interaction, service_id: @service.id, interaction_id: @interaction.id)
      @link = FactoryGirl.create(:link, local_authority_id: @local_authority.id, service_interaction_id: @service_interaction.id)
      @expected_body = {
        "local_authority"=>{
          "name"=>"Blackburn",
        },
        "local_interaction"=>{
          "url"=>"http://local-authority-name-1.example.com/service-label-1/interaction-label-1"
        }
      }
    end

    it "returns json success" do
      login_as_stub_user
      get :show, local_authority_slug: @local_authority.slug, service_slug: @service.slug, slug: @interaction.slug, format: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq(@expected_body)
    end

    it "returns json success for numeric slugs" do
      login_as_stub_user
      get :show, local_authority_slug: @local_authority.slug, service_slug: 2, slug: 4, format: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq(@expected_body)
    end
  end
end
