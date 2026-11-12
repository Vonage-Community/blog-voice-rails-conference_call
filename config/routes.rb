Rails.application.routes.draw do
  # Vonage calls the answer URL with GET or POST, depending on how the application is configured.
  match "/webhooks/answer", to: "conference#answer", via: %i[ get post ]
  post "/webhooks/event", to: "conference#event"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
