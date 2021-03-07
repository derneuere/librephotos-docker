#!/bin/sh

# below can be leverged for runtime variable replacement against index.html.
# sed -i 's~window.env={initialized:!1}~window.env={initialized:true,REACT_APP_SENTRY_DSN:"'"$REACT_APP_SENTRY_DSN"'",REACT_APP_BACKEND_URL:"'"$REACT_APP_BACKEND_URL"'"}~g' /usr/share/nginx/html/index.html

# ln -s index.html 404.html

exec "$@"
