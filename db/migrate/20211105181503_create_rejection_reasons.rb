class CreateRejectionReasons < ActiveRecord::Migration[6.1]
  def change
    create_table :rejection_reasons do |t|
      t.string :codigo
      t.text :description

      t.timestamps
    end
  end
end
