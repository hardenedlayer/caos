class SelectionsController < ApplicationController
  before_action :set_selection, only: [:show, :edit, :update, :destroy]

  # GET /selections
  # GET /selections.json
  def index
    @selections = Selection.all
  end

  # GET /selections/1
  # GET /selections/1.json
  def show
  end

  # GET /selections/new
  def new
    @selection = Selection.new
  end

  # GET /selections/1/edit
  def edit
  end

  # POST /selections
  # POST /selections.json
  def create
    @selection = Selection.new(selection_params)
    @selection.photos = Array.new
    params[:photos].each do |k,v|
      @selection.photos.push(eval(k))
    end

    respond_to do |format|
      if @selection.save
        format.html { redirect_to @selection, notice: 'i18n.selection.created' }
        format.json { render :show, status: :created, location: @selection }
      else
        format.html { render :new }
        format.json { render json: @selection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /selections/1
  # PATCH/PUT /selections/1.json
  def update
    respond_to do |format|
      if @selection.update(selection_params)
        format.html { redirect_to @selection, notice: 'i18n.selection.updated' }
        format.json { render :show, status: :ok, location: @selection }
      else
        format.html { render :edit }
        format.json { render json: @selection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /selections/1
  # DELETE /selections/1.json
  def destroy
    @selection.destroy
    respond_to do |format|
      format.html { redirect_to selections_url, notice: 'i18n.selection.destroyed' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_selection
      @selection = Selection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def selection_params
      params.require(:selection).permit(:user_id, :album_id, :photos)
    end
end
