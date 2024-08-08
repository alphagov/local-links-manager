RSpec.describe "Broken Links Page", type: :request do
  it_behaves_like "only GDS Editors can visit", "/"
end
