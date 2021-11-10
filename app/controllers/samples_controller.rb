class SamplesController < ApplicationController
  before_action :time_params, only: :twelve

  # funcao que vai chamar o indicador 12
  def twelve
    @mic = {}
    @total_mic = Sample.area_analitica('MIC').where('data_recepcao >= ? AND data_recepcao <= ? ', "#{@start_time}", "#{@end_time}")
    segmentation
  end

  # funcao que pede a data o periodo para inserir no indicador 12
  def ask_time
    twelve
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
    if params.present?
      @start_time = Date.new("#{params["start_time(1i)"]}".to_i,"#{params["start_time(2i)"]}".to_i,"#{params["start_time(3i)"]}".to_i)
      @end_time = Date.new("#{params["end_time(1i)"]}".to_i,"#{params["end_time(2i)"]}".to_i,"#{params["end_time(3i)"]}".to_i)
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
    hash[:finalizada] = segment.finalizada.count
    hash[:aguardando] = segment.aguardando.count
    rejeitadas = segment.rejeitada
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
end
