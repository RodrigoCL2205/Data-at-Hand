class SamplesController < ApplicationController

  def indicator
    @mic = {}
    segmentation
    @total = Sample.area_analitica('MIC').count
    @finalizadas = samples_count(@mic, 'finalizada')
    @aguardando = samples_count(@mic, 'aguardando')
  end

  private

  def segmentation
    # PACPOA: contagem separada por matriz e programa = PACPOA
    matriz_pacpoa = ['CARNE', 'LEITE', 'OVO', 'PESCADO']
    matriz_pacpoa.each do |matriz|
      segment = Sample.area_analitica('MIC').programa('PACPOA').matriz(matriz)
      @mic["PACPOA_#{matriz}"] = status_count(segment)
    end

    # PNCP: contagem separada por programa
    pncp = ['Listeria', 'Aves', 'STEC', 'Suínos']
    pncp.each do |name|
      segment = Sample.area_analitica('MIC').programa(name)
      @mic["PNCP_#{name}"] = status_count(segment)
    end

    # Bebidas nao alcoolicas: amostras de origem vegetal
    bebidas = Sample.area_analitica('MIC').matriz('VEGETAL')
    @mic['bebidas'] = status_count(bebidas)

    # Outros
    @mic['outros'] = others('MIC', @mic)
  end

  def others(area_analitica, hash)
    outros = {}
    outros[:total] = Sample.area_analitica(area_analitica).count - samples_count(hash, 'total')
    outros[:finalizada] = Sample.area_analitica(area_analitica).finalizada.count - samples_count(hash, 'finalizada')
    outros[:aguardando] = Sample.area_analitica(area_analitica).aguardando.count - samples_count(hash, 'aguardando')
    return outros
  end

  def status_count(segment)
    hash = {}
    hash[:total] = segment.count
    hash[:finalizada] = segment.finalizada.count
    hash[:aguardando] = segment.aguardando.count
    return hash
  end

  def samples_count(hash, status)
    soma = 0
    hash.each do |key, value|
      soma += value[status.to_sym]
    end
    return soma
  end
end
