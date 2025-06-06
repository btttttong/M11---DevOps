FROM node:22-alpine
WORKDIR /usr/app
COPY package.json package.json
RUN npm install
COPY index.js index.js
CMD ["node", "index.js"]