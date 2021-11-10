class Sample < ApplicationRecord
  belongs_to :client
  has_many :rejections
  has_many :rejection_reasons, through: :rejections

  scope :area_analitica, ->(name) { where(area_analitica: name) }
  scope :programa, ->(name) { where('programa ILIKE ?', "%#{name}%") }
  scope :matriz, ->(name) { where('matriz ILIKE ?', "%#{name}%") }
  scope :finalizada, -> { where(status: 'A', liberada: true ) }
  scope :aguardando, -> { where(liberada: false) }
  # scope :aguardando, ->(end_time) { where(liberada: false).or(where('liberada ILIKE true AND data_liberacao < ?', "#{end_time}")) }
  scope :rejeitada, -> { where(status: 'R', liberada: true) }
  scope :rejeitada_interno, -> {includes(:rejection_reasons).where('rejection_reasons.codigo ILIKE ?', "%R13%").references(:rejection_reasons) }
end
