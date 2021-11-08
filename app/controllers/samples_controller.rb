class SamplesController < ApplicationController
  def index
    @samples = Sample.where(area_analitica: 'MIC')
  end
end
