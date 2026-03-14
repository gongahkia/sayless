.PHONY: setup dev frontend-dev backend-dev frontend-test frontend-build backend-test smoke-api docker-up docker-down

all: dev

setup:
	./scripts/bootstrap.sh

dev:
	./dev.sh

frontend-dev:
	cd frontend && npm run dev

backend-dev:
	cd backend && mix phx.server

frontend-test:
	cd frontend && npm run test

frontend-build:
	cd frontend && npm run build

backend-test:
	cd backend && mix test

smoke-api:
	./scripts/smoke_api.sh

docker-up:
	docker compose up --build

docker-down:
	docker compose down
