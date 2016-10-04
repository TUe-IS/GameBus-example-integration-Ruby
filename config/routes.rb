require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == 'not-just-any-admin' && password == 'just-a-random-password-for-protection'
end if Rails.env.production?

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get :connect, to: 'sessions#connect'
  patch :login, to: 'sessions#rvs_login'
  get :status, to: 'sessions#status'
  get :disconnect, to: 'sessions#disconnect'


  mount Sidekiq::Web => '/sidekiq'
end
