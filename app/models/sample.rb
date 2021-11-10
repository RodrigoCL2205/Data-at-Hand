class Sample < ApplicationRecord
  belongs_to :client
  has_many :rejections
  has_many :rejection_reasons, through: :rejections

  scope :area_analitica, ->(name) { where(area_analitica: name) }
  scope :programa, ->(name) { where('programa ILIKE ?', "%#{name}%") }
  scope :matriz, ->(name) { where('matriz ILIKE ?', "%#{name}%") }
  scope :finalizada, ->(end_time) { where("status = 'A' AND liberada = true AND data_liberacao <= ?", "#{end_time}") }
  scope :aguardando, ->(end_time) { where(liberada: false).or(where('liberada = true AND data_liberacao > ?', "#{end_time}")) }
  scope :rejeitada, ->(end_time) { where("status ILIKE 'R' AND liberada = true AND data_liberacao <= ?", "#{end_time}") }
  scope :rejeitada_interno, -> {includes(:rejection_reasons).where('rejection_reasons.codigo ILIKE ?', "%R13%").references(:rejection_reasons) }
end
