require 'rails_helper'

describe LinkApiResponsePresenter do
  describe '#present' do
    let(:authority) { FactoryGirl.build(:local_authority) }
    let(:presenter) { described_class.new(authority, link) }

    context 'link is present' do
      let(:link) { FactoryGirl.build(:link) }
      let(:expected_response) do
        {
          "local_authority" => {
            "name" => authority.name,
            "snac" => authority.snac,
            "tier" => authority.tier.name,
            "homepage_url" => authority.homepage_url
          },
          "local_interaction" => {
            "lgsl_code" => link.service.lgsl_code,
            "lgil_code" => link.interaction.lgil_code,
            "url" => link.url
          }
        }
      end

      it 'returns combined details for the local authority and local interaction' do
        expect(presenter.present).to eq(expected_response)
      end
    end

    context 'no link is present' do
      let(:link) { nil }
      let(:expected_response) do
        {
          "local_authority" => {
            "name" => authority.name,
            "snac" => authority.snac,
            "tier" => authority.tier.name,
            "homepage_url" => authority.homepage_url
          }
        }
      end

      it 'returns details for just the local authority' do
        expect(presenter.present).to eq(expected_response)
      end
    end
  end
end
