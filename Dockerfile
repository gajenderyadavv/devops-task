# -- Node.js app ----------
FROM node:18-alpine AS builder

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install --production

COPY . .

EXPOSE 3000

CMD ["npm", "start"]

# --  NGINX ----------
#FROM nginx:1.27-alpine

#RUN rm -rf /usr/share/nginx/html/*

#COPY --from=builder /usr/src/app/public /usr/share/nginx/html

#EXPOSE 80

#CMD ["nginx", "-g", "daemon off;"]