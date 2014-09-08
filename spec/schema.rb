ActiveRecord::Schema.define version: 0 do
  create_table "documents", force: true do |t|
    t.string :owner
    t.string :original_file_name
    t.string :original_content_type
    t.integer :original_updated_at
    t.integer :original_file_size
  end
end