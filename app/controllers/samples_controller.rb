class SamplesController < ApplicationController
  before_action :time_params, only: :twelve
  before_action :tabela_mic, only: :twelve
  before_action :find, only: :show

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

  def index
    @samples = Sample.all
    @clients = Client.all
    @rejections = Rejection.all
    # @samples = Sample.page(params[:page])
    # Será utilizado para verificar quais tabelas serão mostradas ao usuário
    @show = {
      status: false,
      programa: false,
      matriz: false,
      area_analitica: false,
      client_name: false,
      client_city: false,
      client_state: false,
      codigo_rejeicao: false
    }

    if params[:status].present?
      @samples = @samples.collect { |sample| sample if sample.status == params[:status] }.compact
      @show[:status] = true

    end

    if params[:programa].present?
      @samples = @samples.collect { |sample| sample if sample.programa == params[:programa] }.compact
      @show[:programa] = true
    end

    if params[:matriz].present?
      @samples = @samples.collect { |sample| sample if sample.matriz == params[:matriz] }.compact
      @show[:matriz] = true
    end

    if params[:area_analitica].present?
      @samples = @samples.collect { |sample| sample if sample.area_analitica == params[:area_analitica] }.compact
      @show[:area_analitica] = true
    end

    if params[:rg].present?
      @samples = @samples.collect { |sample| sample if sample.rg == params[:rg] }.compact
      @show[:rg] = true
    end

    if params[:client_name].present?
      @client = @clients.collect { |client| client if client.name == params[:client_name] }.compact.first
      @samples = @samples.collect { |sample| sample if sample.client == @client }.compact
      @show[:client_name] = true
    end

    if params[:client_city].present?
      @clients = @clients.collect { |client| client if client.city == params[:client_city] }.compact
      @samples = @samples.collect { |sample| sample if @clients.include?(sample.client) }.compact
      @show[:client_city] = true
    end

    if params[:client_state].present?
      @clients = @clients.collect { |client| client if client.state == params[:client_state] }.compact
      @samples = @samples.collect { |sample| sample if @clients.include?(sample.client) }.compact
      @show[:client_state] = true
    end

    if params[:codigo_rejeicao].present?
      @rejections = @rejections.collect do |rejection|
        rejection if rejection.rejection_reason.codigo == params[:codigo_rejeicao]
      end
      @rejections = @rejections.compact
      samples_in_rejections = []
      @rejections.each { |rejection| samples_in_rejections << rejection.sample }.uniq
      @samples = @samples.collect { |sample| sample if samples_in_rejections.include?(sample) }.compact
      @show[:codigo_rejeicao] = true
    end
  end

  def show; end

  def query
    import_names
  end

  private

  def find
    @sample = Sample.find(params[:id])
  end

  # converte os dados de params em start_time e end_time
  def time_params
    if params[:twelve].present?
      #@start_time = Date.new("#{params["start_time(1i)"]}".to_i,"#{params["start_time(2i)"]}".to_i,"#{params["start_time(3i)"]}".to_i)
      #@end_time = Date.new("#{params["end_time(1i)"]}".to_i,"#{params["end_time(2i)"]}".to_i,"#{params["end_time(3i)"]}".to_i)
      #params.require(:twelve).permit(:start_time, :end_time)
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

  # def sample_params
  #   params.require(:sample).permit(:client_id, :sample_number, :programa,
  #      :matriz, :subgrupo, :produto, :rg, :area_analitica, :objetivo_amostra,
  #      :liberada, :latente, :descartada, :status, :data_recepcao,
  #      :data_liberacao, :data_descarte)
  # end

  def import_names
    @statuss = Sample.all.distinct.pluck(:status)
    @programas = Sample.all.order('programa ASC').distinct.pluck(:programa)
    @clients_name = Sample.all.distinct.pluck(:client_id).collect { |client_id| Client.find(client_id).name }.sort.uniq
    @clients_city = Sample.all.distinct.pluck(:client_id).collect { |client_id| Client.find(client_id).city }.sort.uniq
    @clients_state = Sample.all.distinct.pluck(:client_id).collect { |client_id| Client.find(client_id).state }.sort.uniq
    @matrizes = Sample.all.order('matriz ASC').distinct.pluck(:matriz)
    @areas_analiticas = Sample.all.order('area_analitica ASC').distinct.pluck(:area_analitica)
    @rgs = Sample.all.order('rg ASC').distinct.pluck(:rg)
    @codigos_rejeicoes = RejectionReason.all.order('codigo ASC').distinct.pluck(:codigo)
  end
end
