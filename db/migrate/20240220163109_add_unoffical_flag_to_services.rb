class AddUnofficalFlagToServices < ActiveRecord::Migration[7.1]
  def change
    change_table :services, bulk: true do |t|
      t.boolean :unofficial, default: false
    end
  end
end
