# Simple Webhook receiver

Provide code and container for a simple webhook receiver for testing purpose

## Getting Started

```bash
# Run webhook receiver
docker run -d --rm -p 8282:80 titom73/webhook-receiver:dev

# Send manual webhook
cd tests/
curl -d @webhook-message.json -H 'Content-Type: application/json' http://localhost:8282/receiver
{"color":"Red","fruit":"Apple","size":"Large"}
```

Webhook received can be monitored from the container:

```bash
docker logs --follow 961
 * Serving Flask app 'webhook-receiver' (lazy loading)
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: off
 * Running on all addresses (0.0.0.0)
   WARNING: This is a development server. Do not use it in a production deployment.
 * Running on http://127.0.0.1:80
 * Running on http://172.17.0.2:80 (Press CTRL+C to quit)
 {
     "color": "Red",
     "fruit": "Apple",
     "size": "Large"
 }
```

Docker image now support `amd64` and `arm64`. It means you can run this server on a embedded platform like raspberry pi 4

## Available receivers

- `/receiver`: Just print out complete message received by the server

## Python code.

Code can be installed locally using pip:

```bash
pip install .
```

Script options are:

- `--debug`: to activate Flask debug mode
- `--port`: to configure port to use to listen webhook. (default is `80`)

## Build docker image

```bash
docker build -t titom73/webhook-receiver:latest .
```

## License

Code is under [Apache2 License](./LICENSE)
