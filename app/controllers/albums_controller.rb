class AlbumsController < ApplicationController
  before_action :set_album, only: [:show, :edit, :update, :destroy]

  # GET /albums
  # GET /albums.json
  def index
    @albums = Album.all
  end

  # GET /albums/1
  # GET /albums/1.json
  def show
    conn = SoftLayer::ObjectStorage::Connection.new({
      username: @album.username,
      api_key: @album.api_key,
      network: @album.network.to_sym,
      datacenter: @album.datacenter.to_sym
    })
    cont = conn.container(@album.container)
    data = cont.search()

    @items = []
    data[:items].each do |item|
      if not item['content_type'].eql? 'application/directory'
        obj = cont.object(item['name'])
        item['bytes'] = obj.bytes
        item['last_modified'] = obj.last_modified
        item['etag'] = obj.etag
        item['src'] = obj.temp_url(30)
        item['filename'] = File.basename(item['name'])
        @items.push item
        debug "ITEM #{item}"
      end
    end
  end

  # GET /albums/new
  def new
    begin
      @user = User.find(session[:user_id])
      @album = @user.albums.new
    rescue
      return redirect_to root_path
    end
  end

  # GET /albums/1/edit
  def edit
  end

  # POST /albums
  # POST /albums.json
  def create
    @album = Album.new(album_params)

    respond_to do |format|
      if @album.save
        format.html { redirect_to @album, notice: 'i18n.album.album_created' }
        format.json { render :show, status: :created, location: @album }
      else
        format.html { render :new }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /albums/1
  # PATCH/PUT /albums/1.json
  def update
    respond_to do |format|
      if @album.update(album_params)
        format.html { redirect_to @album, notice: 'i18n.album.album_updated' }
        format.json { render :show, status: :ok, location: @album }
      else
        format.html { render :edit }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /albums/1
  # DELETE /albums/1.json
  def destroy
    @album.destroy
    respond_to do |format|
      format.html { redirect_to albums_url, notice: 'Album was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_album
      @album = Album.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def album_params
      params.require(:album).permit(:title, :username, :api_key, :network, :datacenter, :container, :user_id)
    end
end
