
FROM ubuntu:latest
# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
# Update the package list and install Apache
RUN apt-get update && \
    apt-get install -y apache2 && \
    apt-get clean
# Copy your application code to Apache's default root directory
COPY ./code /var/www/html/
# Expose port 80 to the outside world
EXPOSE 80
# Start Apache in the foreground
CMD ["apachectl", "-D", "FOREGROUND"]
