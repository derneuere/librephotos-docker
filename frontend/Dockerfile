FROM node:15 as builder

RUN apt-get update && apt-get install -y curl git xsel

WORKDIR /usr/src/app
RUN git clone https://github.com/LibrePhotos/librephotos-frontend .
RUN npm ci --quiet
RUN npm run build

FROM nginx:alpine
EXPOSE 3000

WORKDIR /usr/share/nginx
COPY ./entrypoint.sh .
WORKDIR /usr/share/nginx/html

COPY --from=builder /usr/src/app/build/ .

COPY ./nginx.conf /etc/nginx/conf.d/default.conf

ENTRYPOINT [ "sh", "/usr/share/nginx/entrypoint.sh" ]

CMD ["nginx", "-g", "daemon off;"]
