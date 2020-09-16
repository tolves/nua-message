Rails.application.routes.draw do

  root :to => 'messages#index'
  #get 'payment' => 'payment#index'
  resources :payments
  resources :messages

end
