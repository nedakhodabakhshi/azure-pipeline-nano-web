FROM httpd:2.4

# Update and install Apache, wget, unzip
RUN apt update && apt upgrade -y && \
    apt install wget unzip -y

# Download and unzip the template
WORKDIR /tmp
RUN wget https://www.tooplate.com/zip-templates/2108_dashboard.zip && \
    unzip 2108_dashboard.zip && \
    cp -r 2108_dashboard/* /usr/local/apache2/htdocs/

# Expose Apache port
EXPOSE 80

