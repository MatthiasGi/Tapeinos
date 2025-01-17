# Events hold dates that are assigned to plans. They allow servers to enroll for
#    specific dates inside a plan.

class Event < ApplicationRecord

  # Each event *must* be linked to a plan.
  belongs_to :plan
  validates :plan, presence: true

  # An event without a date wouldn't make any sense, would it?
  validates :date, presence: true

  validates :needed, numericality: { only_integer: true, greater_than: 0 },
    if: :needed

  # The servers can enroll to many events.
  has_and_belongs_to_many :servers

  # ============================================================================

  # Check, how many servers have already enrolled to an event.
  def enrolled
    servers.size
  end

  # Creates a list of all associated servers as short list.
  def list_servers
    servers.sort_by(&:to_s).map(&:shortname).join(', ')
  end

end
