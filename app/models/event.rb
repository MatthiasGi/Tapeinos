class Event < ActiveRecord::Base

  # Each event *must* be linked to a plan.
  belongs_to :plan
  validates :plan, presence: true

  # An event without a date wouldn't make any sense, would it?
  validates :date, presence: true

  validates :needed, numericality: { only_integer: true, greater_than: 0 }, if: :needed

end
