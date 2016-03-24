class CreateAlbums < ActiveRecord::Migration
  def change
    create_table :albums do |t|
      t.string :title
      t.string :username
      t.string :api_key
      t.string :network
      t.string :datacenter
      t.string :container
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
