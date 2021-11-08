# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


require 'json'
require 'open-uri'
require 'csv'

puts 'Cleaning clients database...'
Client.destroy_all

puts 'Starting clients seed...'

path = Rails.root.join('db','estados-cidades.json')

uf_cidades_url = File.read(path)
estados_cidades = JSON.parse(uf_cidades_url)

100.times do
  estado = estados_cidades['estados'].sample
  nome_estado = estado['nome']

  cidade = estado['cidades'].sample

  client = Client.create(
  name: Faker::Company.name,
  state: nome_estado,
  city: cidade)
  puts "Included #{client.name}"
end

puts "Clients insert succesfully"

puts "Destoying all Samples."
Sample.destroy_all
puts "All samples destroyed."

puts "parsing Samples CSV file."

csv_options = { col_sep: ',', quote_char: '"', headers: :first_row }
filepath    = File.dirname(__FILE__) + "/2021114_11557_dado_bruto_form_049.csv"

CSV.foreach(filepath, csv_options) do |row|
  if Sample.where(sample_number: row['sample_number']) == []
    puts "Creating sample."
    sample = Sample.new(
      sample_number: row['sample_number'],
      client_id: 1,
      data_recepcao: row['data_de_recepcao'],
      programa: row['programa'],
      matriz: row['matriz'],
      subgrupo: row['subgrupo'],
      rg: row['rg'],
      area_analitica: row['area_analitica'],
      status: row['status'],
      objetivo_amostra: row['objetivo_da_amostra'],
      liberada: row['liberada'] == 'T',
      data_liberacao: row['data_da_liberacao'],
      latente: row['latente'] == 'T',
      descartada: row['descartada'],
      data_descarte: row['data_do_descarte']
    )
    sample.save!
    puts "Created sample #{sample.id}"
  else
    puts "Sample #{row['sample_number']} already exists"
  end
end

puts "Parsing finished!"