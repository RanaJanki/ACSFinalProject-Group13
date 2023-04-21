#!/bin/bash

export Name=Terraform


sudo mkdir /var/www/html/files


sudo yum -y update
sudo yum -y install httpd


#echo curl http://169.254.169.254/latest/meta-data/tags
#myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`


sudo curl -0 https://acs1129.s3.amazonaws.com/index.html --output /var/www/html/index.html

#dgfdfgdfg
sudo sed -i "s/{{ owner }}/$Name/g" /var/www/html/index.html


sudo wget https://acs1129.s3.amazonaws.com/files/daffodil.jpeg -P /var/www/html/files

sudo wget https://acs1129.s3.amazonaws.com/files/daisy.jpeg -P /var/www/html/files

sudo wget https://acs1129.s3.amazonaws.com/files/hibiscus.jpeg -P /var/www/html/files

sudo wget https://acs1129.s3.amazonaws.com/files/lilly.jpeg -P /var/www/html/files

sudo wget https://acs1129.s3.amazonaws.com/files/rose.jpeg -P /var/www/html/files

sudo wget https://acs1129.s3.amazonaws.com/files/sunflower.jpeg -P /var/www/html/files

sudo wget https://acs1129.s3.amazonaws.com/files/tulip.jpeg -P /var/www/html/files



sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl restart httpd

