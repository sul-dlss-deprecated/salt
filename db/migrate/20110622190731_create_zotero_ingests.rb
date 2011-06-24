class CreateZoteroIngests < ActiveRecord::Migration
  def self.up
    create_table :zotero_ingests do |t|
      t.timestamp :start_date
      t.timestamp :finish_date
      t.text :message
      t.string :filename

      t.timestamps
    end
  end

  def self.down
    drop_table :zotero_ingests
  end
end
