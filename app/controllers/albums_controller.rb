class AlbumsController < ApplicationController
  before_action :set_album, only: [:show, :photo, :edit, :update, :destroy]

  # GET /albums
  # GET /albums.json
  def index
    @albums = Album.all
  end

  # GET /albums/1
  # GET /albums/1.json
  def show
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

  def photo
    FileUtils.mkpath('tmp/thumbs')
    cache = "tmp/thumbs/#{params[:etag]}-#{params[:object]}"
    debug cache

    if cache && File.exists?(cache)
      debug "File exists: #{cache}. using it!"
      image = MiniMagick::Image.open(cache)
    else
      obj = cont.object(URI.decode(params[:object]))
      debug "Generate Thumb from #{obj.temp_url(30)}..."
      image = MiniMagick::Image.open(obj.temp_url(30))
      resize_with_crop(image, 200, 200)
      image.write(cache)
    end
    send_data image.to_blob, type: 'image/jpg', disposition: 'inline'
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

    def cont
      conn = SoftLayer::ObjectStorage::Connection.new({
        username: @album.username,
        api_key: @album.api_key,
        network: @album.network.to_sym,
        datacenter: @album.datacenter.to_sym
      })
      conn.container(@album.container)
    end

    # https://gist.github.com/maxivak/3924976
    def resize_with_crop(img, w, h, options = {})
      gravity = options[:gravity] || :center
      w_original, h_original = [img[:width].to_f, img[:height].to_f]
      op_resize = ''
      if w_original * h < h_original * w
        op_resize = "#{w.to_i}x"
        w_result = w
        h_result = (h_original * w / w_original)
      else
        op_resize = "x#{h.to_i}"
        w_result = (w_original * h / h_original)
        h_result = h
      end

      w_offset, h_offset = crop_offsets_by_gravity(
        gravity, [w_result, h_result], [ w, h])

      img.combine_options do |i|
        i.resize(op_resize)
        i.gravity(gravity)
        i.crop "#{w.to_i}x#{h.to_i}+#{w_offset}+#{h_offset}!"
      end

      img
    end

    GRAVITY_TYPES = [ :north_west, :north, :north_east, :east, :south_east, :south, :south_west, :west, :center ]
    def crop_offsets_by_gravity(
      gravity, original_dimensions, cropped_dimensions)
      raise(ArgumentError, "Gravity must be one of #{GRAVITY_TYPES.inspect}") unless GRAVITY_TYPES.include?(gravity.to_sym)
      raise(ArgumentError, "Original dimensions must be supplied as a [ width, height ] array") unless original_dimensions.kind_of?(Enumerable) && original_dimensions.size == 2
      raise(ArgumentError, "Cropped dimensions must be supplied as a [ width, height ] array") unless cropped_dimensions.kind_of?(Enumerable) && cropped_dimensions.size == 2

      original_width, original_height = original_dimensions
      cropped_width, cropped_height = cropped_dimensions

      vertical_offset = case gravity
        when :north_west, :north, :north_east
          then 0
        when :center, :east, :west
          then [ ((original_height - cropped_height) / 2.0).to_i, 0 ].max
        when :south_west, :south, :south_east
          then (original_height - cropped_height).to_i
      end

      horizontal_offset = case gravity
        when :north_west, :west, :south_west
          then 0
        when :center, :north, :south
          then [ ((original_width - cropped_width) / 2.0).to_i, 0 ].max
        when :north_east, :east, :south_east
          then (original_width - cropped_width).to_i
      end

      return [ horizontal_offset, vertical_offset ]
    end
end
