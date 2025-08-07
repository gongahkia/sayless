all: dev

dev:
	cd backend && mix deps.clean --all && mix clean && mix deps.get && mix phx.server