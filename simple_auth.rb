require 'sinatra'
require 'json'

require_relative 'models/auth'
require_relative 'db/db'

enable :sessions
use Rack::Logger
Db::Database.load

LOGIN_ERROR_MESSAGE = 'Неправильное имя пользователя или пароль'.freeze
LOGGED_IN_MESSAGE = 'Вы уже авторизованы'.freeze

INCORRECT_PASSWORD_MESSAGE = 'Пароль не соответсвует требованиям'.freeze
MATCH_ERROR_PASSWORD_MESSAGE = 'Пароли должны совпадать'.freeze
USER_EXIST_MESSAGE = 'Пользователь с таким именем уже существует'.freeze
USER_BLOCKED_MESSAGE = 'Данный пользователь заблокирован. Вход невозможен'.freeze
USER_OLD_PASSWORD_MATCH_ERROR = 'Вы ввели неправильный пароль'.freeze

# def login_required()
#   @user = session['user']
#   return 403 unless @user.exists?
# end

def user
  return nil unless session[:user]

  Db::Database.find_user session[:user]
end

def admin
  return nil unless session[:user]

  user = Db::Database.find_user session[:user]
  return nil unless user.admin?

  user
end

error 403 do
  'Доступ запрещен'
end

error 404 do
  'Страница не найдена'
end

get '/' do
  # puts Db::Database.users
  # @error_message = LOGIN_ERROR_MESSAGE

  redirect '/user/login'
end

get '/user/login' do
  erb :login
end

post '/user/login' do
  username = params['username']
  password = params['password']

  logger.info "LOGIN WITH username: #{username}, password: #{password}"
  user = Auth::User.login(username, password)

  if user
    @error_message = USER_BLOCKED_MESSAGE if user.blocked?
  else
    @error_message = LOGIN_ERROR_MESSAGE
  end

  return erb :login if @error_message

  session[:user] = user.to_s
  redirect '/user/change_password' if user.empty_password?

  if user.admin?
    redirect '/admin'
  else
    redirect '/user/profile'
  end
end

get '/user/logout' do
  @user = session[:user]
  return 403 unless @user

  session.clear
  redirect '/'
end

get '/user/profile' do
  @user = session[:user]
  return 403 unless @user

  erb :profile
end

# Signup
get '/user/signup' do
  @enable_error = LOGGED_IN_MESSAGE if session[:user]

  erb :signup
end

post '/user/signup' do
  username = params['username']
  password = params['password']
  password_2 = params['password_2'] # Повторный ввод

  is_valid = true

  if Auth::User.uniq? username
    is_valid = false
    @error_message ||= USER_EXIST_MESSAGE
  end

  unless password == password_2
    is_valid = false
    @error_message ||= MATCH_ERROR_PASSWORD_MESSAGE
  end

  unless Auth::User.password_valid? password
    is_valid = false
    @error_message ||= INCORRECT_PASSWORD_MESSAGE
  end

  if is_valid
    Db::Database.create_user({
      "username" => username,
      "password" => password
    })
    redirect '/'
  end

  erb :signup
end

get '/user/change_password' do
  @user = user

  return 403 unless @user

  return erb :change_pass
end

post '/user/change_password' do
  @user = user
  return 403 unless @user

  logger.info "CHANGE PASSWORD WITH old: #{params['old_password']}, new: #{params['new_password']}"
  @error_message = USER_OLD_PASSWORD_MATCH_ERROR unless @user.change_password(params['old_password'], params['new_password'])

  return erb :change_pass if @error_message

  redirect 'user/login'
end

post '/user/block/:name' do
  @user = admin
  return 404 unless @user

  target = Db::Database.find_user params['name']
  target.block

  redirect '/admin'
end

# Admin
get '/admin' do
  @users = Db::Database.users
  @user = admin
  return 404 unless @user

  erb :admin
end

get '/admin/add_user' do
  @user = admin
  return 404 unless @user

  erb :add_user
end

post '/admin/add_user' do
  @user = admin
  return 404 unless @user

  username = params['username']
  unless Auth::User.uniq? username
    @error_message = USER_EXIST_MESSAGE
    return erb :add_user
  end

  Db::Database.create_user({
    'username' => username,
    'password' => '',
    'is_validating' => true
  })

  redirect '/admin'
end
