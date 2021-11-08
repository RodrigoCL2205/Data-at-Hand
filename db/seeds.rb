# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


# Seed Client
states = %w(AC, AL, AP, AM, BA, CE, DF, ES, GO, MA, MT, MS, PA, PB, PR, PE, PI, RJ, RN, RS, RO, RR, SC, SP, SE, TO)
cities = ["Abadia de Goiás", "Abadia dos Dourados", "Abadiânia", "Abaetetuba", "Abaeté", "Abaiara", "Abaré", "Abatiá", "Abaíra", "Abdon Batista", "Abel Figueiredo",
"Abelardo Luz", "Abre Campo", "Abreu e Lima", "Abreulândia", "Acaiaca", "Acajutiba", "Acarapé", "Acaraú", "Acari", "Acará", "Acauã", "Aceguá", "Acopiara", "Acorizal",
"Acrelândia", "Acreúna", "Adamantina", "Adelândia", "Adolfo", "Adrianópolis", "Adustina", "Afogados da Ingazeira", "Afonso Bezerra", "Afonso Cláudio", "Afonso Cunha",
"Afrânio", "Afuá", "Agrestina", "Agricolândia", "Agrolândia", "Agronômica", "Aguanil", "Aguaí", "Agudo", "Agudos", "Agudos do Sul", "Aguiar", "Aguiarnópolis", "Aimorés",
"Aiquara", "Aiuaba", "Aiuruoca", "Ajuricaba", "Alagoa", "Alagoa Grande", "Alagoa Nova", "Alagoinha", "Alagoinha do Piauí", "Alagoinhas", "Alambari", "Albertina",
"Alcantil", "Alcinópolis", "Alcobaça", "Alcântara", "Alcântaras", "Aldeias Altas", "Alecrim", "Alegre", "Alegrete", "Alegrete do Piauí", "Alegria", "Alenquer", "Alexandria",
"Alexânia", "Alfenas", "Alfredo Chaves", "Alfredo Marcondes", "Alfredo Vasconcelos", "Alfredo Wagner", "Algodão de Jandaíra", "Alhandra", "Aliança", "Aliança do Tocantins",
"Almadina", "Almas", "Almeirim", "Almenara", "Almino Afonso", "Almirante Tamandaré", "Almirante Tamandaré do Sul", "Aloândia", "Alpercata", "Alpestre", "Alpinópolis",
"Alta Floresta", "Alta Floresta d'Oeste", "Altair", "Altamira", "Altamira do Maranhão", "Altamira do Paraná", "Altaneira", "Alterosa", "Altinho", "Altinópolis", "Alto Alegre",
"Alto Alegre do Maranhão", "Alto Alegre do Parecis", "Alto Alegre do Pindaré", "Alto Araguaia", "Alto Bela Vista", "Alto Boa Vista",
"Alto Caparaó", "Alto Feliz", "Alto Garças", "Alto Horizonte", "Alto Jequitibá", "Alto Longá", "Alto Paraguai", "Alto Paraná", "Alto Paraíso", "Alto Paraíso de Goiás",
"Alto Parnaíba", "Alto Piquiri", "Alto Rio Doce", "Alto Rio Novo", "Alto Santo", "Alto Taquari", "Alto do Rodrigues", "Altos", "Altônia", "Alumínio", "Alvarenga",
"Alvarães", "Alvinlândia", "Alvinópolis"]
puts "Seed Client begins!"
Client.destroy_all
puts "Clients clean!"
puts "Creating clients..."
100.times do |i|
  Client.create!(
    name: Faker::Name.name,
    city: cities.sample,
    state: states.sample
  )
end
puts "Seed Client completed!"

require 'csv'

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

