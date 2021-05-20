ActiveRecord::Migration.verbose = false

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :email, null: false
    t.string :password_digest, null: false
    t.integer :token_version, null: false, default: 0
    t.index :email, unique: true
    t.index [:id, :token_version], unique: true
  end
end
