FROM node:20-alpine
RUN npm install -g pnpm
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm approve-builds esbuild && pnpm install
COPY . .
EXPOSE 5000
CMD ["pnpm", "dev"]

