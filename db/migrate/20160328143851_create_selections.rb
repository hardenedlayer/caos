class CreateSelections < ActiveRecord::Migration
  def change
    create_table :selections do |t|
      t.references :user, index: true, foreign_key: true
      t.references :album, index: true, foreign_key: true
      t.text :photos

      t.timestamps null: false
    end
  end
end
