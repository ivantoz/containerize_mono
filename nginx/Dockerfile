FROM nginx:1.23.2
LABEL maintainer="Ivan"

#set build time variables
###################################################
ARG APP_UID=1000
ARG APP_GID=1000
ARG APP_USER=nginx
ARG APP_GROUP=nginx

#modify user/group of existing user
###################################################
RUN usermod -u "$APP_UID" "$APP_USER" && \
    groupmod -g "$APP_GID" "$APP_GROUP"

#remove default nginx config
##################################################    
RUN rm /etc/nginx/conf.d/default.conf 

COPY nginx/nginx.conf /etc/nginx/nginx.conf
