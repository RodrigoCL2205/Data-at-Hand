class SamplesController < ApplicationController
before_action :time_params, only: :twelve
before_action :tabela_mic, only: :twelve
before_action :form_fields, only: :custom_search

  def index
  end

  def custom_search
    @query

    segment = Sample.all
    segment.matriz([@query[:matriz]]) if params[:matriz].present?
    segment.area_analitica([@query[:area_analitica]]) if params[:area_analitica].present?
    if params[:status].present?
    end

    index
  end

  # funcao que vai chamar o indicador 12
  def twelve
    @mic = {}
    @total_mic = Sample.area_analitica('MIC').where('data_recepcao >= ? AND data_recepcao <= ? ', "#{@start_time}", "#{@end_time}")
    segmentation
  end

  # funcao que pede a data o periodo para inserir no indicador 12
  def ask_time
    # twelve
  end

  # funcao que vai chamar o indicador 02
  def two
  end

  # funcao que vai chamar o indicador 30
  def thirty
  end

  private

  # converte os dados de params em start_time e end_time
  def time_params
    if params[:twelve].present?
      @start_time = params[:twelve][:start_time].to_date
      @end_time = params[:twelve][:end_time].to_date

    else
      @start_time = Date.new(Time.now.year,1,1)
      @end_time = Date.new(Time.now.year,12,31)
    end
  end

  # separa a segmentacao: area analitica MIC
  def segmentation
    # Total
    @mic["total"] = status_count(@total_mic)

    # PACPOA: contagem separada por matriz e programa = PACPOA
    matriz_pacpoa = ['CARNE', 'LEITE', 'OVO', 'PESCADO']
    matriz_pacpoa.each do |matriz|
      segment = @total_mic.programa('PACPOA').matriz(matriz)
      @mic["PACPOA_#{matriz}"] = status_count(segment)
    end

    # PNCP: contagem separada por programa
    pncp = ['Listeria', 'Aves', 'STEC', 'Suínos']
    pncp.each do |name|
      segment = @total_mic.programa(name)
      @mic["PNCP_#{name}"] = status_count(segment)
    end

    # Bebidas nao alcoolicas: amostras de origem vegetal
    bebidas = @total_mic.matriz('VEGETAL')
    @mic['bebidas'] = status_count(bebidas)

    # Outros
    @mic['outros'] = others(@mic)
  end

  # conta as amostras que nao constam nos programas indicados anteriormente
  def others(hash)
    outros = {}
    outros[:total] = hash['total'][:total] - samples_count(hash, 'total')
    outros[:finalizada] = hash['total'][:finalizada] - samples_count(hash, 'finalizada')
    outros[:aguardando] = hash['total'][:aguardando] - samples_count(hash, 'aguardando')
    outros[:rejeitada_interno] = hash['total'][:rejeitada_interno] - samples_count(hash, 'rejeitada_interno')
    outros[:rejeitada_externo] = hash['total'][:rejeitada_externo] - samples_count(hash, 'rejeitada_externo')
    return outros
  end

  # separa as amostras por status e conta as quantidades
  def status_count(segment)
    hash = {}
    hash[:total] = segment.count
    hash[:finalizada] = segment.finalizada(@end_time).count
    hash[:aguardando] = segment.aguardando(@end_time).count
    rejeitadas = segment.rejeitada(@end_time)
    hash[:rejeitada_interno] = rejeitadas.rejeitada_interno.count
    hash[:rejeitada_externo] = rejeitadas.count - hash[:rejeitada_interno]
    return hash
  end

  # conta o total de cada status da area analitica(usada para calcular outros)
  def samples_count(hash, status)
    soma = 0
    hash.each do |key, value|
      soma += value[status.to_sym] unless key == 'total'
    end
    return soma
  end

  def tabela_mic
    @tabela_mic = [
      ['PACPOA_CARNE', 'PACPOA - Carnes e produtos cárneos'],
      ['PACPOA_LEITE', 'PACPOA - Leite e produtos lácteos'],
      ['PACPOA_OVO', 'PACPOA - Ovos e derivados'],
      ['PACPOA_PESCADO', 'PACPOA - Pescados e produtos da pesca'],
      ['PNCP_Listeria', 'PNCP - Listeria monocytogenes em produtos de origem animal'],
      ['PNCP_Aves', 'PNCP - Salmonella spp. em carcaças de frangos e perus (IN 20/2016)'],
      ['PNCP_STEC', 'PNCP - Escherichia coli e Salmonella spp. em carne bovina (IN 60/2018)'],
      ['PNCP_Suínos', 'PNCP - Salmonella spp. em superfície de carcaça de suínos (IN 60/2018)'],
      ['outros', 'Outros programas'],
      ['bebidas', 'Bebidas não alcoólicas'],
      ['total', 'Total']
    ]
  end

  def form_fields
    @sample_fields = {}

    # campos da tabela Sample
    array = ['matriz', 'area_analitica', ]
    array.each do |item|
      segment = Sample.select(item.to_sym).order(item.to_sym).distinct
      nomes = []
      segment.each do |sample|
        nomes << sample[item.to_sym]
      end
      @sample_fields[item.to_sym] = nomes
    end

    # status da amostra
    @sample_fields[:status] = ['Finalizada', 'Rejeitada', 'Aguardando']

    # campo rejeicao - tabela Rejection
    segment = RejectionReason.order(:codigo).all
    @rejection_reasons = []
    segment.each do |reason|
      @rejection_reasons << [reason[:codigo], reason[:description]]
    end

    # campo UF - tabela Client
    @uf = [
      'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 
      'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
    ]
  end
end
