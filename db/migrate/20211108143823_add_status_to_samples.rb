class AddStatusToSamples < ActiveRecord::Migration[6.1]
  def change
    add_column :samples, :status, :string
  end
end
