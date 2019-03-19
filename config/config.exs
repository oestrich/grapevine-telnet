use Mix.Config

config :phoenix, :json_library, Jason
config :telnet, :pubsub, start: true
config :telnet, :errors, report: false

if File.exists?("config/#{Mix.env()}.exs") do
  import_config("#{Mix.env()}.exs")
end
