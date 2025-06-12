# Use official Apache base image
FROM httpd:2.4

# Set build-time argument for zip URL
ARG ZIP_URL

# Install required tools and download the website
# Download and unzip the template
WORKDIR /tmp
RUN wget https://www.tooplate.com/zip-templates/2108_dashboard.zip && \
    unzip 2108_dashboard.zip && \
    cp -r 2108_dashboard/* /var/www/html/

# Expose HTTP port
EXPOSE 80

