Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  post 'open_ai/create'
  root 'home#index'
  get 'open_ai/upload', to: 'open_ai#upload'
  get '/open_ai/upload_image', to: 'open_ai#upload'
  # post 'open_ai/upload', to: 'open_ai#upload_image'
  post 'open_ai/upload_image'

  post '/upload_image_api', to: 'open_ai#upload_image_api'

  get 'open_ai/analyze', to: 'open_ai#analyze'

end
