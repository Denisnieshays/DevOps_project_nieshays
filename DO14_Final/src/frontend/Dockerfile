FROM node:18
WORKDIR /frontend
COPY package.json .
RUN npm install --legacy-peer-deps
COPY . .
EXPOSE 5173
CMD ["npm", "run", "dev"]
