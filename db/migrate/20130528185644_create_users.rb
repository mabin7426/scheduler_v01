class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :email
      t.string :token
      t.string :calendar_id

      t.timestamps
    end
  end
end
