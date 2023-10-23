require 'sinatra'
require 'json'

require_relative 'models/auth'
require_relative 'db/db'

enable :sessions
Db::Database.load

ERROR_MESSAGE = 'Login error'

# def login_required()
#   @user = session['user']
#   return 403 unless @user.exists?
# end

error 403 do
  'Access forbidden'
end

get '/' do
  # puts Db::Database.users
  erb :login
end

post '/user/login' do
  username = params['username']
  password = params['password']

  puts "GOT LOGIN WITH #{username} #{password}"
  user = Auth::User.login(username, password)
  
  return ERROR_MESSAGE unless user


  session[:user] = user.to_s

  redirect '/user/profile'
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
