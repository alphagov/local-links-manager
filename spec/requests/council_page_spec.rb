RSpec.describe "Council page", type: :request do
  before { create(:district_council, slug: "north-midlands") }

  it_behaves_like "only GDS Editors can visit", "/local_authorities"
  it_behaves_like "only GDS Editors can visit", "/local_authorities/north-midlands"
  it_behaves_like "only GDS Editors can visit", "/local_authorities/north-midlands/edit_url"
  it_behaves_like "only GDS Editors can visit", "/local_authorities/north-midlands/download_links_form"
  it_behaves_like "only GDS Editors can visit", "/local_authorities/north-midlands/upload_links_form"
end
