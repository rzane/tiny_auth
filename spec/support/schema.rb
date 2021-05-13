ActiveRecord::Migration.verbose = false

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :email, null: false
    t.string :password_digest, null: false
    t.uuid :token_identifier
    t.string :reset_token_digest
    t.datetime :reset_token_expires_at
    t.index :email, unique: true
    t.index :reset_token, unique: true
  end
end
