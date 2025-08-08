#!/bin/bash

clear
echo "LOG: Running dev.sh now..."
echo "LOG: Starting Backend (Elixir/Phoenix)..."
(cd backend && mix phx.server) &
BACKEND_PID=$!
echo "LOG: Starting Frontend (Next.js)..."
(cd frontend && npm run dev) &
FRONTEND_PID=$!
echo "LOG: Backend is running with PID: $BACKEND_PID"
echo "LOG: Frontend is running with PID: $FRONTEND_PID"
echo "LOG: Press Ctrl+C to stop both servers."
trap "echo 'Stopping servers...'; kill $BACKEND_PID $FRONTEND_PID" SIGINT SIGTERM
wait