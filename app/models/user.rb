# This class is used for manging multiple servers. It allows the user of the app
# to login and save settings.

class User < ActiveRecord::Base

  # This user-object holds a collection of servers it manages
  has_many :servers
  accepts_nested_attributes_for :servers

  # Before deleting a user, the servers should be told to safely unlink from the
  # current user
  before_destroy { servers.map &:unlink_user }

  # The email is a unique key to identify a user. Additionally, this simple
  # regex ensures that there is an email and that it contains an @. This is only
  # to prevent really bad typos.
  validates :email,
    format: { with: /@/ },
    uniqueness: { case_sensitive: false }

  # The email should be saved downcase. Because beauty.
  before_save { self.email = email.downcase }

  # Use Rails' already included authentication-method. Saves a lot of work.
  has_secure_password

  # The password should have a minimal length. Security. But only if one is
  # given. If not the user is probably not changing it.
  validates :password,
    presence: true,
    length: { minimum: 6 },
    if: :password

  # ============================================================================

  # This updates the time the server was last used. Should be called by
  # session-managment or similar
  def used
    update last_used: DateTime.now
  end

  # Allows the user to reset his password by creating a reset-token which is
  # returned (only valid for 24 hours)
  def prepare_password_reset
    update password_reset_token: SecureRandom.hex,
      password_reset_expire: 1.day.from_now
    password_reset_token
  end

  # Clears the password-reset, useful e.g. when the password was changed
  # successfully or the user logged in while the procedure is still going
  def clear_password_reset
    update password_reset_token: nil, password_reset_expire: nil,
      failed_authentications: 0
  end

  # Checks if the password is still resetable
  def password_reset_expired?
    password_reset_expire.nil? || password_reset_expire.past?
  end

  # The authentication failed, increment the counter
  def failed_authentication
    increment! :failed_authentications
  end

  # The user has failed authenticating too many times, block him
  def blocked?
    failed_authentications >= 5
  end

  # :nodoc:
  def to_s
    email
  end

end
