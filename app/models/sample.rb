class Sample < ApplicationRecord
  paginates_per 50

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

  def self.to_csv
    CSV.generate(headers: true, col_sep: ";") do |csv|
      csv << ["RG", "Nome do cliente", "Município", "Estado", "Programa",
        "Matriz", "Subgrupo", "Produto", "Área Analítica", "Objetivo da Amostra",
        "Data da recepção", "Latente?", "Status", "Liberada?", "Data da liberação",
        "Descartada?", "Data do descarte"]
      sigla_status = {'U': "Não recebida", 'I': "Incompleta", 'P': 'Em processamento', 
        'C': 'Completa', 'A': 'Autorizada', 'R': "Rejeitada", 'X': "Cancelada"}
      all.each do |sample|
        sample.liberada? ? liberada = "Sim" : liberada = "Não"
        sample.latente? ? latente = "Sim" : latente = "Não"
        sample.descartada? ? descartada = "Sim" : descartada = "Não"
        status = sigla_status[sample.status]
        sample.data_descarte.nil? ? data_descarte = "" : data_descarte = sample.data_descarte.strftime("%d/%m/%y")
        sample.data_liberacao.nil? ? data_liberacao = "" : data_liberacao = sample.data_liberacao.strftime("%d/%m/%y")
        row = [sample.rg, sample.client.name, sample.client.city, sample.client.state, sample.programa,
        sample.matriz, sample.subgrupo, sample.produto, sample.area_analitica, sample.objetivo_amostra,
        sample.data_recepcao.strftime("%d/%m/%y"), latente, status, liberada, data_liberacao,
        descartada, data_descarte ]
        csv << row
      end
    end
  end

end
