FROM python:3.11-alpine

WORKDIR /app

COPY server_node.py /app/server_node.py

EXPOSE 5004

CMD ["python", "server_node.py", "--port", "5004", "--name", "Node 4 - Docker Container", "--platform", "Docker WSL 2", "--color", "#a855f7"]
