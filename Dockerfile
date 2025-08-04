# syntax=docker/dockerfile:1
# Multi-stage build for the FluxBridge service.
FROM golang:1.22-alpine AS build
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -o /out/server ./cmd/server

FROM alpine:3.20
RUN adduser -D -u 10001 appuser
WORKDIR /app
COPY --from=build /out/server /app/server
USER appuser
EXPOSE 8080
ENTRYPOINT ["/app/server"]
