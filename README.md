# Pokemon Type Calculator

A microservice built in Crystal with [Athena](https://github.com/athena-framework/athena).

It's designed to be deployed to AWS lambda however, it can be deployed to a server if preferred. If deploying serverlessly, ensure you set the environment variable `SERVERLESS` to `true` in your functions configuration. This will ensure we circumvent the http server that is utilized for dev environments.
