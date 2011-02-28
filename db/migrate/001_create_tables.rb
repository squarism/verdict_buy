# base migration

class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :loves do |t|
      t.integer :ars_review_id
      t.string :gb_title
      #t.string :ars_title
      t.string :title

      t.timestamps
    end
    
    create_table :shop_list_items do |t|
      t.integer :ars_review_id
      t.integer :loves_id

      t.timestamps
    end
    
    create_table :ars_reviews do |t|
      t.string :article_title
      t.string :link
      t.string :date

      t.timestamps
    end
    add_index(:ars_reviews, :link, :unique => true)
    
    create_table :ars_titles do |t|
      t.string  :title
      t.integer :ars_review_id

      t.timestamps
    end
  end

  def self.down
    drop_table :loves
    drop_table :shop_list_items
    drop_table :ars_reviews
    drop_table :ars_titles
  end
end
