all: dev

dev:
	cd backend && \
	-mix deps.clean parse_trans --force && \
	mix deps.get && \
	mix phx.server