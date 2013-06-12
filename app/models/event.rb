class Event < ActiveRecord::Base
  attr_accessible :all_day, :breakup, :category, :due, :duration, :end, :notes, :priority, :recurring, :start, :task, :title, :user_id

  belongs_to :user

  validates :title, presence: true
  validates :priority, presence: true
  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 0}, length: {maximum: 86400}
end
