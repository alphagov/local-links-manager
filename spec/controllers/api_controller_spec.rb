require 'rails_helper'

RSpec.describe ApiController, type: :controller do
  before do
    @local_authority = FactoryGirl.create(:local_authority, name: 'Blackburn', slug: 'blackburn')
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

  describe "GET #local_interaction_details" do
    it "returns http success" do
      login_as_stub_user
      get :service_interaction_for_local_authority, authority_slug: 'blackburn', lgsl: 2, lgil: 4
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq(@expected_body)
    end
  end
end
