class CreateUserRole < ActiveRecord::Migration[6.0]
  def change
    create_table :roles do |t|
      t.string :name
      t.string :alias
      t.timestamps
    end
  end
end
