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
    context = HTTP::Server::Context.new(req, HTTP::Server::Response.new(io))

    ADI.container.athena_routing_route_handler.handle context

    res = Lambda::Builder::HTTPResponse.new(
      context.response.status_code,
      io.to_s.split("\n").last,
    )

    # not super efficient
    # serializing to JSON string and then parsing so we return JSON::Any
    JSON.parse(res.to_json)
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
