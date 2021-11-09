class Sample < ApplicationRecord
  belongs_to :client
  has_many :rejection_reasons, through: :rejection

  scope :area_analitica, ->(name) { where(area_analitica: name) }
  scope :programa, ->(name) { where('programa ILIKE ?', "%#{name}%") }
  scope :matriz, ->(name) { where('matriz ILIKE ?', "%#{name}%") }
  scope :finalizada, -> { where(status: 'A', liberada: true) }
  scope :aguardando, -> { where(liberada: false) }
  scope :exceto_programa, ->(array) { where.not(array) }
end
