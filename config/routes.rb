Rails.application.routes.draw do
  post 'user/register', action: :register, controller: 'users', as: 'register'
  post 'user/login', action: :login, controller: 'users', as: 'login'
  



  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
