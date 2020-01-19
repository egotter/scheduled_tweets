class CreateCredentials < ActiveRecord::Migration[6.0]
  def change
    create_table :credentials do |t|
      t.bigint :user_id, null: false
      t.string :token, null: false
      t.string :secret, null: false

      t.timestamps null: false

      t.index :user_id, unique: true
    end
  end
end
