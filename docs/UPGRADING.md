# Upgrading

## 2.x to 3.x

- Change all occurences of `generate_reset_token` to use `generate_token`.
- Change all occurences of `exchange_reset_token` to use `find_by_token`.
- Add a new migration:

```ruby
change_table :users do |t|
  t.remove :reset_token_digest
  t.remove :reset_token_expires_at

  t.integer :token_version, null: false, default: 0
  t.index [:id, :token_version], unique: true
end
```
