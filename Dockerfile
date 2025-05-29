# build stage
FROM golang:1.24-alpine AS builder
WORKDIR /app
COPY main.go .
RUN go build -o main main.go

# runtime stage
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/main .
EXPOSE 4444
CMD ["./main"]