all:dev

dev:dev.sh
	./dev.sh

frontend-dev:
	cd frontend && npm install && npm run dev

backend-dev:
	cd backend && mix deps.clean --all && mix clean && mix deps.get && mix phx.server