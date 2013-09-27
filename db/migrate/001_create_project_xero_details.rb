class CreateProjectXeroDetails < ActiveRecord::Migration
 
 def self.up
    
    #create the new table
    create_table :project_xero_details do |t|
      t.references :project
      t.column :xero_contact_id, :string
      t.column :rate, :decimal, :precision => 19, :scale => 2
    end
    
    # add a foreign key
    execute <<-SQL
      ALTER TABLE project_xero_details
        ADD CONSTRAINT fk_project_xero_details_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
    SQL
 
    add_index :project_xero_details, :project_id
    add_index :project_xero_details, :xero_contact_id

  end

  def self.down

    execute <<-SQL
      ALTER TABLE project_xero_details
        DROP FOREIGN KEY fk_project_xero_details_project
    SQL

    drop_table :project_xero_details
  end

end

 