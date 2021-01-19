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

# TODO:
# Fork the lambda build runtime, pass in Lambda::Builder::HTTPRequest
# to the handler instead of just the body. Then make a response class.
# The handler only has to return the response object. This will allow us
# to forgo the to_json, JSON.parse, to_json that it's currently going through.

# runtime.register_handler("httpevent") do |request|
#   context = HTTP::Server::Context.new(req, HTTP::Server::Response.new(io))

#   art_res = ADI.container.athena_routing_route_handler.handle context

#   Lambda::Builder::HTTPResponse.new(
#     art_res.status_code,
#     art_res.body,
#   )
# end
