require "json"
require "athena"
require "lambda_builder"

require "./data/pokemon"
require "./data/types"
require "./controller"

def serverless
  runtime = Lambda::Builder::Runtime.new

  runtime.register_handler("httpevent") do |input|
    io = IO::Memory.new
    req = Lambda::Builder::HTTPRequest.new(input)
    res = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(req, res)

    ADI.container.athena_routing_route_handler.handle context

    pp res

    # not super efficient, serializing to JSON string and then parsing, simplify this
    JSON.parse Lambda::Builder::HTTPResponse.new(res.status_code, res.output.to_s).to_json
  end

  pp "Serverless is waiting for events"
  runtime.run
rescue e : Exception
  pp e
end

# Run the server
def main
  if ENV["SERVERLESS"]?
    serverless
  else
    ART.run
  end
end

main()
