all: dev

dev:
	cd backend && (mix deps.clean parse_trans || true) && mix deps.get && mix phx.server