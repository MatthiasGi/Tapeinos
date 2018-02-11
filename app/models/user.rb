# This class is used for manging multiple servers. It allows the user of the app
#    to login and save settings.

class User < ApplicationRecord

  # This user-object holds a collection of servers it manages.
  has_many :servers
  accepts_nested_attributes_for :servers

  # Before deleting a user, the servers should be told to safely unlink from the
  #    current user.
  before_destroy { servers.map(&:unlink_user) }

  # The email is a unique key to identify a user. Additionally, this simple
  #    regex ensures that there is an email and that it contains an @. This is
  #    only to prevent really bad typos.
  validates :email,
    format: { with: /@/ },
    uniqueness: { case_sensitive: false }

  # The email should be saved downcase. Because beauty.
  before_save { self.email = email.downcase }

  # Use Rails' already included authentication-method. Saves a lot of work.
  has_secure_password

  # The password should have a minimal length. Security. But only if one is
  #    given. If not the user is probably not changing it.
  validates :password,
    presence: true,
    length: { minimum: 6 },
    if: :password

  # The role sets the user's rights.
  #    - A user can only access the non-administrative interface.
  #    - The admin has access to the administrative interface but not to the
  #      core configuration and isn't also able to manage users.
  #    - Root has access to everything.
  enum role: [ :user, :admin, :root ]

  # There must be at least one root at any given time, this validation makes
  #    sure of that.
  validate do |user|
    # The validation is not necessary:
    #    - on creating an object (no id yet set or no current user found in db),
    #    - if the role-changing user wasn't a root-user,
    #    - if the user is not changing his role (root changing to root).
    user.id and old = User.find(user.id) and old.root? and !user.root? or next

    # If there aren't enough other root-users, set the error message.
    msg = I18n.t('activerecord.attributes.user/errors.role.one_root_needed')
    User.where(role: User.roles[:root]).count > 1 or user.errors[:role] << msg
  end

  # ============================================================================

  # This updates the time the user was last used. Should be called by
  #    session-managment or similar.
  def used
    update(last_used: DateTime.now)
  end

  # Allows the user to reset his password by creating a reset-token which is
  #    returned (only valid for 24 hours).
  def prepare_password_reset
    update(
      password_reset_token: SecureRandom.hex,
      password_reset_expire: 1.day.from_now
    )
    password_reset_token
  end

  # Clears the password-reset, useful e.g. when the password was changed
  #    successfully or the user logged in while the procedure is still going.
  def clear_password_reset
    update(
      password_reset_token: nil,
      password_reset_expire: nil,
      failed_authentications: 0
    )
  end

  # Checks if the password is still resettable.
  def password_reset_expired?
    password_reset_expire.nil? || password_reset_expire.past?
  end

  # The authentication failed, increment the counter.
  def failed_authentication
    increment! :failed_authentications
  end

  # The user has failed authenticating too many times, block him.
  def blocked?
    failed_authentications >= 5
  end

  # Two roles are qualified for general administration: admin and root. This
  #    function checks whether one of these roles is present. More general than
  #    just simply `admin?`.
  def administrator?
    admin? or root?
  end

  # :nodoc:
  def to_s
    email
  end

end
