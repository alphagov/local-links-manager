class AllowNullUrlOnLinks < ActiveRecord::Migration[5.0]
  def change
    change_column_null :links, :url, true
  end
end
