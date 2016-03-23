class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :mail
      t.string :name
      t.text :comment
      t.string :password_digest
      t.datetime :password_at
      t.text :perms

      t.timestamps null: false
    end
    add_index :users, :mail, unique: true
  end
end
