require 'sinatra'

require_relative 'models/auth'

enable :sessions

get '/' do
  erb :login
end

post '/user/login' do
  ERROR_MESSAGE = 'Login error'

  login = params['login']
  password = params['password']

  user = Auth::User.login(login, password)
  
  return ERROR_MESSAGE unless user


  response = "You are #{user.name}"
  session[:user] = user.to_s

  response
end
