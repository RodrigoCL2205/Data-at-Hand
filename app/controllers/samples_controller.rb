class SamplesController < ApplicationController
before_action :time_params, only: :twelve
before_action :tabela_mic, only: :twelve
before_action :import_names, only: :query
before_action :siglas, only: :index


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

  # exibir resultados da busca personalizada
  def index
    @rejections = Rejection.all
    # Será utilizado para verificar quais tabelas serão mostradas ao usuário parametros tabela samples
    search_fields = [
      ['status', 'samples'],
      ['programa', 'samples'],
      ['matriz', 'samples'],
      ['area_analitica', 'samples'],
      ['rg', 'samples'],
      ['name', 'client'],
      ['city', 'client'],
      ['state', 'client'],
      ['codigo_rejeicao', 'rejection_reasons']
    ]
    @samples = Sample.all
    segment = Sample.where('matriz'.to_sym =>'CARNE')
    search_fields.each do |item|
      if item[1] == 'client'
        value = "client_#{item[0]}".to_sym
      else
        value = item[0].to_sym
      end
      if params[:query][value].present?
        case item[1]
        when 'samples'
          @samples = @samples.where(item[0].to_sym => params[:query][item[0]])
        when 'client'
          @samples = @samples.includes(:client).where("clients.#{item[0]}".to_sym => params[:query]["client_#{item[0]}"])
        when 'rejection_reasons'
          @samples = @samples.includes(:rejection_reasons).where("rejection_reasons.codigo".to_sym => params[:query][:codigo_rejeicao]).references(:rejection_reasons)
        end

      end
    end
    @quantidade = @samples.count
    @samples = @samples.page(params[:page])
  end


  def show
    @sample = Sample.find(params[:id])
  end

  # selecionar opcoes para a busca personalizada
  def query
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

  def siglas
    @sigla_programas = {
      "Atendimento ao Consolidado de requisitos complementares à exportação aos Estados Unidos e à IN º 60/2018." => "Requisitos Complementares IN 60/2018",
      "PACPOA - Programa de Avaliação de Conformidade de Produtos de Origem Animal" => "PACPOA",
      "PROGRAMA NACIONAL DE CONTROLE DE RESÍDUOS E CONTAMINANTES - ÁREA ANIMAL" => "PNCRC",
      "Programa de Controle STEC (IN 60/2018)" => "PNCP E. coli",
      "Programa de Controle de Listeria Monocytogenes (IN 09/2009)" => "PNCP Listeria",
      "Programa de Redução de Patógenos em Aves (IN 20/2016)" => "PNCP Salmonella"
      }

    @uf = [
      ["AC","Acre"],
      ["AL","Alagoas"],
      ["AP","Amapá"],
      ["AM","Amazonas"],
      ["BA","Bahia"],
      ["CE","Ceará"],
      ["DF","Distrito Federal"],
      ["ES","Espírito Santo"],
      ["GO","Goiás"],
      ["MA","Maranhão"],
      ["MT","Mato Grosso"],
      ["MS","Mato Grosso do Sul"],
      ["MG","Minas Gerais"],
      ["PR","Paraná"],
      ["PB","Paraíba"],
      ["PA","Pará"],
      ["PE","Pernambuco"],
      ["PI","Piauí"],
      ["RN","Rio Grande do Norte"],
      ["RS","Rio Grande do Sul"],
      ["RJ","Rio de Janeiro"],
      ["RO","Rondônia"],
      ["RR","Roraima"],
      ["SC","Santa Catarina"],
      ["SE","Sergipe"],
      ["SP","São Paulo"],
      ["TO","Tocantins"]
    ]
  end
end
