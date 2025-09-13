# -- Node.js app ----------
FROM node:18-alpine AS builder

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install --production

COPY . .

EXPOSE 3000

CMD ["npm", "start"]


#----for multistage build ---but not needed in this case as of its app size is already small and no dependency or code issues is being raised in the alpine image of Node18.
# --  NGINX ----------
#FROM nginx:1.27-alpine

#RUN rm -rf /usr/share/nginx/html/*

#COPY --from=builder /usr/src/app/public /usr/share/nginx/html

#EXPOSE 80

#CMD ["nginx", "-g", "daemon off;"]