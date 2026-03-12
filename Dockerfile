# build stage
FROM golang:1.22-alpine AS builder

WORKDIR /korst-backend

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o korst-backend ./cmd

# runtime stage
FROM alpine:3.19

WORKDIR /root/

COPY --from=builder /korst-backend/korst-backend .

EXPOSE 5040

CMD ["./korst-backend"]



