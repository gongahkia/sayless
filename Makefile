all: dev

dev:
	cd backend && (mix deps.clean parse_trans --force || true) && mix deps.get && mix phx.server