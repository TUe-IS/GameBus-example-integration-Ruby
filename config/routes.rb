require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == 'admin' && password == Rails.application.secrets.sidekiq_password
end if Rails.env.production?

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get :connect, to: 'sessions#connect'
  patch :login, to: 'sessions#rvs_login'
  get :status, to: 'sessions#status'
  get :disconnect, to: 'sessions#disconnect'

  mount Sidekiq::Web => '/sidekiq'
end
