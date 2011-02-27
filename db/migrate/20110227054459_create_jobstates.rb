class CreateJobstates < ActiveRecord::Migration
  def self.up
    create_table :jobstates do |t|
      t.string :name
      t.boolean :running
      t.date :started

      t.timestamps
    end
  end

  def self.down
    drop_table :jobstates
  end
end
