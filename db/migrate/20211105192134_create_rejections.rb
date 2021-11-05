class CreateRejections < ActiveRecord::Migration[6.1]
  def change
    create_table :rejections do |t|
      t.references :sample, null: false, foreign_key: true
      t.references :rejection_reason, null: false, foreign_key: true
      t.text :comment

      t.timestamps
    end
  end
end
