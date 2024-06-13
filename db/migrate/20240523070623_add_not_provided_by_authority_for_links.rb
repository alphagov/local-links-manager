class AddNotProvidedByAuthorityForLinks < ActiveRecord::Migration[7.1]
  def change
    add_column :links, :not_provided_by_authority, :boolean, default: false, null: false
  end
end
