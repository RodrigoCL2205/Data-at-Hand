# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

puts 'creating rejections reasons'

puts 'cleaning Rejections Reasons database'
RejectionReason.destroy_all

ocorrencias = File.dirname(__FILE__) + "/ocorrencias.csv"

CSV.foreach(ocorrencias, { col_sep: ';' }) do |row|
  rejection = RejectionReason.create!(codigo: row[0], description: row[1])
  puts "Added #{rejection.codigo}"
end

puts 'Rejections Reasons seeded'
