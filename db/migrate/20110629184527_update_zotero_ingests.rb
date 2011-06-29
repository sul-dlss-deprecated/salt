class UpdateZoteroIngests < ActiveRecord::Migration
  def self.up
    remove_column :zotero_ingests, :start_date
    remove_column :zotero_ingests, :finish_date
    add_column :zotero_ingests, :ingest_start, :timestamp
    add_column :zotero_ingests, :ingest_end, :timestamp
    add_column :zotero_ingests, :index_start, :timestamp
    add_column :zotero_ingests, :index_end, :timestamp
    add_column :zotero_ingests, :check_start, :timestamp
    add_column :zotero_ingests, :check_end, :timestamp
    
  end

  def self.down
     add_column :zotero_ingests, :start_date
      add_column :zotero_ingests, :finish_date
      remove_column :zotero_ingests, :ingest_start, :timestamp
      remove_column :zotero_ingests, :ingest_end, :timestamp
      remove_column :zotero_ingests, :index_start, :timestamp
      remove_column :zotero_ingests, :index_end, :timestamp
      remove_column :zotero_ingests, :check_start, :timestamp
      remove_column :zotero_ingests, :check_end, :timestamp
  end
end
