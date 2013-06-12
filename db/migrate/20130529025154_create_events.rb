class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :category
      t.string :title
      t.datetime :start
      t.datetime :end
      t.integer :duration
      t.boolean :breakup
      t.boolean :all_day
      t.text :notes
      t.string :priority
      t.datetime :due
      t.boolean :recurring
      t.boolean :task
      t.string :user_id

      t.timestamps
    end
  end
end
