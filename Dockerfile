# Use official Apache base image
FROM httpd:2.4

# Set build-time argument for zip URL
ARG ZIP_URL

# Install required tools and download the website
RUN apt-get update && \
    apt-get install -y wget unzip && \
    wget $ZIP_URL -O /tmp/site.zip && \
    unzip /tmp/site.zip -d /tmp/website && \
    cp -r /tmp/website/* /usr/local/apache2/htdocs/ && \
    rm -rf /tmp/site.zip /tmp/website

# Expose HTTP port
EXPOSE 80

