class CreateSamples < ActiveRecord::Migration[6.1]
  def change
    create_table :samples do |t|
      t.string :client
      t.string :name
      t.string :city
      t.string :state

      t.timestamps
    end
  end
end
