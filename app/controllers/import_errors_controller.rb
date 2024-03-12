class ImportErrorsController < ApplicationController
  # GET /imports/:id/errors
  def index
    @import = Import.find(params[:id])
    @import_errors = @import.import_errors
  end
end
