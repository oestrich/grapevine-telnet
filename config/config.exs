use Mix.Config

config :telnet, :errors, report: false
config :telnet, :metrics, server: true, host: [port: 4100]

if File.exists?("config/#{Mix.env()}.exs") do
  import_config("#{Mix.env()}.exs")
end
