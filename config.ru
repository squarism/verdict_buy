# This file is used by Rack-based servers to start the application.

# holy ass, serving static files in rails 3 is a bitch
use Rack::Static, urls: [ "/images" ], root: "public"

require ::File.expand_path('../config/environment',  __FILE__)
run ArsLovesGames::Application
