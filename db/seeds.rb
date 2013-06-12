# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
class CreateEvents < ActiveRecord::Migration

  Event.destroy_all

  # def change
  #   create_table :events do |t|
  #     t.string :category
  #     t.string :title
  #     t.datetime :start
  #     t.datetime :end
  #     t.integer :duration
  #     t.boolean :breakup
  #     t.boolean :all_day
  #     t.text :notes
  #     t.string :priority
  #     t.datetime :due
  #     t.boolean :recurring
  #     t.boolean :task
  #     t.string :user_id

  #     t.timestamps
  #   end

    data = [{title: "Example task", duration: 60, notes: "You can put notes here", priority: "1 = High", task: true}]

    data.each do |task_info|
      m = Event.new
      m.title = task_info[:title]
      m.duration = task_info[:duration]
      m.notes = task_info[:notes]
      m.priority = task_info[:priority]
      m.task = task_info[:task]
      m.notes = task_info[:notes]
      m.save(validate: false)
    # end
  end

end
