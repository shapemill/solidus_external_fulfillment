Spree::Core::Engine.routes.draw do
  # Add your extension routes here

  namespace :admin do
    resources :fulfillment_centers
  end

  get '/ship/:hash_id', to: 'external_fulfillment_requests#show', as: :external_fulfillment_request
  put '/ship/:hash_id', to: 'external_fulfillment_requests#fulfill'
end
