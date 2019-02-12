use Mix.Config

config :telnet, :errors, report: false

if File.exists?("config/#{Mix.env()}.exs") do
  import_config("#{Mix.env()}.exs")
end
