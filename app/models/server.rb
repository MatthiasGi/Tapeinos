# This class contains the server: a kind of user of the interface who can
#    optionally be linked with a "real" user.

class Server < ApplicationRecord

  # Optional linked user-account to make login and password-managment available
  #    to one or more servers.
  belongs_to :user, optional: true

  # The servers can enroll to many events (contained in plans).
  has_and_belongs_to_many :events
  has_and_belongs_to_many :plans

  # The server may be subscribed to multiple messages.
  has_and_belongs_to_many :messages

  # Absolutley mandatory are first- and lastname, as well as sex to identify the
  #    server.
  validates :firstname, :lastname, :sex, presence: true

  # This simple validation ensures that there is an email and that it contains
  #    an @. This is only to prevent really bad typos.
  validates :email, format: { with: /@/ }

  # The email should be saved downcase. Because beauty.
  before_save { self.email = email.downcase }

  # Sex and rank are hardcoded and available as enums.
  enum sex: [ :male, :female ]
  enum rank: [ :novice, :disciple, :veteran, :master ]

  # The rank must be set for each server, it defaults to :novice.
  validates :rank, presence: true

  # Talar and rochet size are limited to integers between certain thresholds,
  #    but they should be optional.
  validates :size_talar,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 100,
      less_than_or_equal_to: 150
    },
    allow_nil: true
  validates :size_rochet,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 60,
      less_than_or_equal_to: 100
    },
    allow_nil: true

  # The seed is used to identify a server without user. So it should be unique
  #    and have only certain characters and length to allow url-usage.
  validates :seed,
    uniqueness: true,
    format: { with: /\A[0-9a-f]{32}\z/ }

  # The seed should be generated automagically if it does not exist already.
  before_validation :generate_seed, unless: :seed

  # The API-Key should be unique as it identifies a server (similar to the
  #    seed). It also should have a specific length
  validates :api_key,
    uniqueness: true,
    allow_nil: true,
    format: { with: /\A[0-9a-f]{32}\z/ }

  # ============================================================================

  # If the server has a linked account, the email should be taken from the user.
  def email
    user.present? ? user.email : self[:email]
  end

  # This function updates the servers seed, it can also be called externally.
  def generate_seed
    update(seed: SecureRandom.hex(16))
  end

  # This updates the time the server was last used. Should be called by session-
  #    managment or similar.
  def used
    update(last_used: DateTime.now)
  end

  # Removes the currently linked user from the server and saves the email.
  def unlink_user
    user and update(email: user.email, user_id: nil)
  end

  # Gathers all related servers: if the server is linked to an user, all other
  #    servers will be selected. If the server is not linked to an user, all
  #    other servers, that are not linked to an user and have the same email-
  #    address, will be selected
  def siblings
    others = user ? user.servers : Server.where(email: email, user_id: nil)
    others.where.not(id: id).to_a
  end

  # Creates a unique as-short-as-possible name for the server.
  def shortname

    # Get all servers, that share the same firstname
    doppelgangers = Server.where(firstname: firstname).where.not(id: id).to_a
    return firstname unless doppelgangers.size > 0

    # Generate an abbreviation of the lastname until there is noone who shares
    #    the same start.
    last = ''
    lastname.each_char do |c|
      last += c
      doppelgangers = doppelgangers.select{ |d| d.lastname.starts_with?(last) }
      break unless doppelgangers.size > 0
    end

    # Only apply a dot if the lastname was actually shortend.
    last == lastname ? "#{firstname} #{lastname}" : "#{firstname} #{last}."
  end

  # Generates a login-token for a personal login-link (see sessions-controller).
  def login_token
    user ? email : seed
  end

  # Generates a new API key which is used to identify a server without login for
  #    API-purposes
  def generate_api_key
    begin
      self.api_key = SecureRandom.hex(16)
    end while self.class.exists?(api_key: api_key)
    self.save
    self.api_key
  end

  # :nodoc:
  def to_s
    "#{firstname} #{lastname}"
  end

end
