class Event < ActiveRecord::Base
  attr_accessible :all_day, :breakup, :category, :due, :duration, :end, :notes, :priority, :recurring, :start, :task, :title, :user_id

  belongs_to :user
end
