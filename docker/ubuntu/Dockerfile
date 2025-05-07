#Step1 : Base Images
FROM ubuntu

# Step2 : Install Program
RUN apt -y update; apt -y upgrade;

# Step3 : File Copy
COPY index.html /var/www/html

#Step4 : Start Nginx
CMD ["nginx", "-g", "daemon off;"]
