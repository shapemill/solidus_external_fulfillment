Spree::Core::Engine.routes.draw do
  # Add your extension routes here

  namespace :admin do
    resources :fulfillment_centers do
    end

    put 'fulfillment_requests/:id/start_preparation', to: 'fulfillment_requests#start_preparation', as: :fulfillment_request_start_preparation
    put 'fulfillment_requests/:id/reset', to: 'fulfillment_requests#reset', as: :fulfillment_request_reset
    post 'fulfillment_requests/:id/resend', to: 'fulfillment_requests#resend', as: :fulfillment_request_resend
  end

  get '/ship/:hash_id', to: 'external_fulfillment_requests#show', as: :external_fulfillment_request
  put '/ship/:hash_id', to: 'external_fulfillment_requests#fulfill'
end
