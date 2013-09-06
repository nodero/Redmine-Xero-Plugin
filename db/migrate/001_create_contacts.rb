class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :contactid
      t.string :name
      t.string :emailaddress
    end
  end
end
