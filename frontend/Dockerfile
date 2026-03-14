FROM node:22-bookworm-slim

WORKDIR /app/frontend

COPY frontend/package.json frontend/package-lock.json ./

RUN npm install

COPY frontend ./

ENV NEXT_PUBLIC_API_BASE_URL=http://localhost:4000

EXPOSE 3000

CMD ["npx", "next", "dev", "--hostname", "0.0.0.0", "--turbopack"]
