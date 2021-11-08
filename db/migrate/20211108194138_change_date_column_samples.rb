class ChangeDateColumnSamples < ActiveRecord::Migration[6.1]
  def change
    remove_column :samples, :data_recepcao
    remove_column :samples, :data_liberacao
    remove_column :samples, :data_descarte

    add_column :samples, :data_recepcao, :date
    add_column :samples, :data_liberacao, :date
    add_column :samples, :data_descarte, :date
  end
end
