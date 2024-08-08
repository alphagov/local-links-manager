RSpec.describe "ServicesPage" do
  before do
    create(:service, label: "Aardvark Wardens", organisation_slugs: %w[department-of-aardvarks])
  end

  it_behaves_like "it is forbidden to non-owners", "/services/aardvark-wardens", "department-of-aardvarks"
  it_behaves_like "it is forbidden to non-owners", "/services/aardvark-wardens/download_links_form", "department-of-aardvarks"
  it_behaves_like "it is forbidden to non-owners", "/services/aardvark-wardens/upload_links_form", "department-of-aardvarks"
end
