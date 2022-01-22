# STEP 1: get ca-certificates and an user
FROM alpine as alpine
RUN apk --no-cache add ca-certificates \
    && adduser -D -h /usr/local/filtron -s /bin/false -u 10001 filtron filtron

# STEP 2: build executable binary
FROM golang:1.17-alpine as builder

WORKDIR $GOPATH/src/github.com/searxng/filtron

# add gcc musl-dev for "go test"
RUN apk add --no-cache git wget

COPY . .
RUN go get -d -v
RUN gofmt -l ./
# RUN go vet -v ./...
# RUN go test -v ./...
RUN CGO_ENABLED=0 go build -ldflags '-extldflags "-static"' -tags timetzdata .

RUN wget -O /rules.json https://raw.githubusercontent.com/searxng/searxng-docker/master/rules.json

# STEP 3: build the image including only the binary
FROM scratch

EXPOSE 4004
EXPOSE 4005
VOLUME /etc/filtron

COPY --from=alpine /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=alpine /etc/passwd /etc/group /etc/
COPY --from=builder /rules.json /etc/filtron/rules.json
COPY --from=builder /go/src/github.com/searxng/filtron/filtron /usr/local/filtron/filtron

USER filtron

ENTRYPOINT ["/usr/local/filtron/filtron", "--rules", "/etc/filtron/rules.json"]
