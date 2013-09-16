require 'rack/reverse_proxy'

use Rack::ReverseProxy do
  reverse_proxy_options preserve_host: true
  reverse_proxy '/', 'http://localhost:3000/'
end
