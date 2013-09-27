class UpdateTimeEntries < ActiveRecord::Migration
  def self.up
    add_column :time_entries, :invoiced, :boolean, default: false
    add_column :time_entries, :invoice_generated, :datetime    
  end

  def self.down
    remove_column :time_entries, :invoiced
    remove_column :time_entries, :invoice_generated
  end
end