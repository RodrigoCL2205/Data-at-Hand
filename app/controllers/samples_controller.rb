class SamplesController < ApplicationController
  before_action :area_analitica

  def indicator
    @pacpoa_samples = @mic.where("programa ILIKE ?", "PACPOA%")
    pacpoa
    pncp
    bebidas_nao_alcoolicas
    @mic_outros = @mic.count - @pacpoa.sum - @listeria.count - @salmonela_frango - @salmonela_suino - @ecoli - @bebidas_nao_alcoolicas
    @listeria_status = {}
    @listeria_status = status(@listeria)
  end

  private

  def area_analitica
    @mic = Sample.where(area_analitica: 'MIC')
  end

  def pacpoa
    matriz_mic = ['CARNE', 'LEITE', 'OVO', 'PESCADO']
    @pacpoa = []
    matriz_mic.each_with_index do |matriz, index|
      @pacpoa[index] = @pacpoa_samples.where(matriz: matriz).count
    end
  end

  def pncp
    @listeria = @mic.where("programa ILIKE ?", "%Listeria%")
    @salmonela_frango = @mic.where("programa ILIKE ?", "%Aves%").count
    @ecoli = @mic.where("programa ILIKE ?", "%STEC%").count
    @salmonela_suino = @mic.where("programa ILIKE ?", "%Superfície%").count
  end

  def bebidas_nao_alcoolicas
    @bebidas_nao_alcoolicas = @mic.where(matriz: "PRODUTOS DE ORIGEM VEGETAL").count
  end

  def status(variavel)
    hash = {}
    hash[:finalizada] = variavel.where(status: 'A', liberada: true).count
    hash[:aguardando] = variavel.where(liberada: false).count
    # hash[:rejeitada_interno] = variavel.where(status: 'R', liberada: true).count
    # hash[:rejeitada_externo] = variavel.where(status: 'R', liberada: false).count
    return hash
  end
end
