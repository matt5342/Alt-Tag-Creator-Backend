Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:5173' # origins to allow

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
