# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'json'
require 'open-uri'

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
