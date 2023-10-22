require_relative 'auth/user'
require_relative 'auth/admin'

module Auth
  USERS = [
    Auth::User.new('user', 'qwerty'),
    Auth::Admin.new('admin', 'qwerty')
  ]
end