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

puts "Destroying all Rejections"
Rejection.destroy_all
puts "All Rejections destroyed"



puts 'Destroying all Samples Rejections Reasons database'
RejectionReason.destroy_all
puts "All Rejections Reasons destroyed."

puts "Destroying all Samples."
Sample.destroy_all
puts "All samples destroyed."

puts 'Cleaning clients database...'
Client.destroy_all
puts 'All Clients destroyed.'

puts 'creating rejections reasons'
ocorrencias = File.dirname(__FILE__) + "/ocorrencias.csv"
CSV.foreach(ocorrencias, { col_sep: ';' }) do |row|
  rejection = RejectionReason.create!(codigo: row[0][1..-1][0..-2], description: row[1])
  puts "Added #{rejection.codigo}"
end
puts 'Rejection Reasons created!'

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


puts "parsing Samples CSV file."

csv_options = { col_sep: ',', quote_char: '"', headers: :first_row }
filepath    = File.dirname(__FILE__) + "/2021114_11557_dado_bruto_form_049.csv"

CSV.foreach(filepath, csv_options) do |row|
  if Sample.where(sample_number: row['sample_number']) == []
    puts "Creating sample."
    sample = Sample.new(
      sample_number: row['sample_number'],
      client_id: Client.all.sample.id,
      data_recepcao: (Date.parse row['data_de_recepcao'] unless row['data_de_recepcao'].nil?),
      programa: row['programa'],
      matriz: row['matriz'],
      subgrupo: row['subgrupo'],
      rg: row['rg'],
      area_analitica: row['area_analitica'],
      status: row['status'],
      objetivo_amostra: row['objetivo_da_amostra'],
      liberada: row['liberada'] == 'T',
      data_liberacao: (Date.parse row['data_da_liberacao'] unless row['data_da_liberacao'].nil?),
      latente: row['latente'] == 'T',
      descartada: row['descartada'],
      data_descarte: (Date.parse row['data_do_descarte'] unless row['data_do_descarte'].nil?)
    )
    sample.save!
    if RejectionReason.where(codigo: row['motivo_de_rejeicao']) != []
      puts "sample id #{sample.id}"
      puts "Creating new Rejection"
      rejection = Rejection.new(
        sample_id: sample.id,
        rejection_reason_id: RejectionReason.where(codigo: row['motivo_de_rejeicao']).first.id
      )

      rejection.save!
      puts "Rejection created!"
    end
    puts "Created sample #{sample.id}"
  else
    if RejectionReason.where(codigo: row['motivo_de_rejeicao']) != []
      p row['motivo_de_rejeicao'].size
      p row['motivo_de_rejeicao']
      puts "Creating new Rejection"
      rejection = Rejection.new(
        sample_id: Sample.where(sample_number: row['sample_number']).first.id,
        rejection_reason_id: RejectionReason.where(codigo: row['motivo_de_rejeicao']).first.id
      )

      rejection.save!
      puts "Rejection created!"
    end
    puts "Sample #{row['sample_number']} already exists"

  end
end

puts "Parsing finished!"
