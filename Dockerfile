FROM golang:1.26.4-bookworm AS builder

WORKDIR /src

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    gcc \
    g++ \
    make \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o cyberstrike-ai cmd/server/main.go


FROM python:3.11-slim-bookworm

WORKDIR /app

ENV PYTHONUNBUFFERED=1
ENV PATH="/app/venv/bin:$PATH"

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    git \
    ca-certificates \
    sqlite3 \
    libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/cyberstrike-ai /app/cyberstrike-ai

COPY requirements.txt /app/requirements.txt
RUN python -m venv /app/venv \
    && /app/venv/bin/pip install --upgrade pip \
    && /app/venv/bin/pip install --no-cache-dir -r /app/requirements.txt

COPY config.yaml /app/config.yaml
COPY web /app/web
COPY tools /app/tools
COPY roles /app/roles
COPY skills /app/skills
COPY agents /app/agents
COPY knowledge_base /app/knowledge_base
COPY mcp-servers /app/mcp-servers
COPY plugins /app/plugins
COPY docs /app/docs

RUN mkdir -p /app/data

EXPOSE 8080 8081

CMD ["/app/cyberstrike-ai", "--config", "/app/config.yaml"]
