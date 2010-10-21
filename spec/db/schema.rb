ActiveRecord::Schema.define(:version => 0) do
  create_table :animals, :force => true do |t|
    t.string :name
    t.string :gender
    t.integer :weight
    t.boolean :active
    t.date :dob
    t.date :created_at
    t.date :updated_at
  end
end