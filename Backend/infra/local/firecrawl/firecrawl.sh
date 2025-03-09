#!/usr/bin/env bash

if test -d .firecrawl/; then
    echo "Firecrawl already exists"
    cd .firecrawl/
    git pull
else
    git clone https://github.com/GetAutomaApp/firecrawl-clone.git .firecrawl/
    cd .firecrawl/
fi

docker compose build
docker compose up -d

echo "🔥 Firecrawl started successfully!"
docker compose ps