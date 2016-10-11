FROM nginx:mainline-alpine
RUN mkdir -p /opt/nginx/trozzy.net/public && \
    rm /etc/nginx/conf.d/default.conf
ADD public/ /opt/nginx/trozzy.net/public
ADD trozzy.net.conf /etc/nginx/conf.d/
EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
