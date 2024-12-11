Beacnox::Engine.routes.draw do
  get "/" => "beacnox#index", :as => :beacnox

  get "/requests" => "beacnox#requests", :as => :beacnox_requests
  get "/crashes" => "beacnox#crashes", :as => :beacnox_crashes
  get "/recent" => "beacnox#recent", :as => :beacnox_recent
  get "/slow" => "beacnox#slow", :as => :beacnox_slow

  get "/trace/:id" => "beacnox#trace", :as => :beacnox_trace
  get "/summary" => "beacnox#summary", :as => :beacnox_summary

  get "/sidekiq" => "beacnox#sidekiq", :as => :beacnox_sidekiq
  get "/delayed_job" => "beacnox#delayed_job", :as => :beacnox_delayed_job
  get "/grape" => "beacnox#grape", :as => :beacnox_grape
  get "/rake" => "beacnox#rake", :as => :beacnox_rake
  get "/custom" => "beacnox#custom", :as => :beacnox_custom
  get "/resources" => "beacnox#resources", :as => :beacnox_resources
end

Rails.application.routes.draw do
  mount Beacnox::Engine => Beacnox.mount_at, :as => "beacnox"
rescue ArgumentError
  # already added
  # this code exist here because engine not includes routing automatically
end
