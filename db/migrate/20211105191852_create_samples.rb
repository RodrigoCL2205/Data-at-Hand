class CreateSamples < ActiveRecord::Migration[6.1]
  def change
    create_table :samples do |t|
      t.references :client, null: false, foreign_key: true
      t.integer :sample_number
      t.string :data_recepcao
      t.string :programa
      t.string :matriz
      t.string :subgrupo
      t.string :produto
      t.string :rg
      t.string :area_analitica
      t.string :objetivo_amostra
      t.boolean :liberada
      t.string :data_liberacao
      t.boolean :latente
      t.boolean :descartada
      t.string :data_descarte

      t.timestamps
    end
  end
end
