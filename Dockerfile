# Use official Apache base image
FROM httpd:2.4

# Set build-time argument for zip URL
ARG ZIP_URL

# Install required tools and download the website
RUN apt-get update && \
    apt-get install -y wget unzip && \
    wget $ZIP_URL -O /tmp/site.zip && \
    unzip /tmp/site.zip -d /usr/local/apache2/htdocs/ && \
    rm /tmp/site.zip

# Expose HTTP port
EXPOSE 80

