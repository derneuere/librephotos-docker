FROM nginx
ENV BACKEND_HOST=backend
ENV FRONTEND_HOST=frontend
COPY ./nginx.conf.template /nginx.conf.template
CMD ["/bin/sh" , "-c" , "envsubst '$BACKEND_HOST $FRONTEND_HOST' < /nginx.conf.template > /etc/nginx/nginx.conf && exec nginx -g 'daemon off;'"]
