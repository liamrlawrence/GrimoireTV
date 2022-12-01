FROM golang:1.19-bullseye
LABEL description="Golang API Server"

# Setup workdir
WORKDIR /usr/src/app
COPY . .

# Install packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends vim

# Pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
RUN go mod download && go mod verify

# Compile app
RUN go build -v -o /usr/local/bin/app ./cmd/sigil

# Run
CMD ["app"]
