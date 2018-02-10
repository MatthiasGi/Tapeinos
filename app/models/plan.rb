# A plan holds many dates allowing the servers to enroll to them.

class Plan < ApplicationRecord

  # The title is the only way for the user to distinguish plans
  validates :title, presence: true

  # The plan holds multiple events which should be also deleted on destroy
  has_many :events, -> { order(:date) }, dependent: :destroy
  accepts_nested_attributes_for :events, allow_destroy: true

  # Multiple servers can enroll for a plan without really attending to an event.
  #    This allows server to simply say: "I don't have time for **any** event."
  has_and_belongs_to_many :servers

  # ============================================================================

  # Returns the earliest event-date associated to the plan
  def first_date
    events.order(:date).first.date.to_date rescue nil
  end

  # Returns the latest event-date associated to the plan
  def last_date
    events.order(:date).last.date.to_date rescue nil
  end

  # :nodoc:
  def to_s
    title
  end

end
