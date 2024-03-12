class ImportsController < ApplicationController
  # GET /imports
  def index
    @category = Category.find(params[:id])
    @imports = @category.imports
    @import = Import.new
  end

  # POST /imports
  def create
    @import = Import.new(import_params)
    if @import.save
      ImportFromFileJob.perform_async(@import.id)
      redirect_to imports_path(@import.category)
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def import_params
      params.require(:import).permit(:category_id, :annotator_id, :list)
    end
end
