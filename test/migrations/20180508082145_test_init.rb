class TestInit < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
    end

    create_table :posts do |t|
      t.string :title
      t.references :user
    end
  end
end
