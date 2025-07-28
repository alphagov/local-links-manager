require "rails_helper"

RSpec.describe "Service tasks" do
  describe "service:enable" do
    it "should create the service" do
      create(:interaction, lgil_code: 1)
      args = Rake::TaskArguments.new(%i[lgsl lgil label slug], [1, 1, "New Service", "new-service"])

      expect { Rake::Task["service:enable"].execute(args) }
        .to change { Service.count }.from(0).to(1)
        .and change { ServiceInteraction.count }.from(0).to(1)
    end

    it "should abort if the interaction LGIL code does not exist" do
      args = Rake::TaskArguments.new(%i[lgsl lgil label slug], [1, 1, "Non Service", "non-service"])

      expect { Rake::Task["service:enable"].execute(args) }.to raise_error(SystemExit, "Interaction [1] does not exist")
    end
  end

  describe "service:destroy" do
    it "should destroy the service" do
      service = create(:service, :all_tiers, lgsl_code: 1)
      service_interaction = create(:service_interaction, service:)
      create_list(:link, 3, service_interaction:)
      args = Rake::TaskArguments.new(%i[lgsl_code], [1])

      expect { Rake::Task["service:destroy"].execute(args) }
        .to change { Service.count }.from(1).to(0)
        .and change { ServiceInteraction.count }.from(1).to(0)
        .and change { Link.count }.from(3).to(0)
    end
  end
end
