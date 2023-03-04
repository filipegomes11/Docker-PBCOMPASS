#!bin/bash

yum update -y
yum install -y docker
yum install -y amazon-efs-utils

systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user
chkconfig docker on

curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
mv /usr/local/bin/docker-compose /bin/docker-compose

curl -sL https://raw.githubusercontent.com/filipegomes11/Compass-Docker/main/docker-compose.yml --output /home/ec2-user/docker-compose.yml

mkdir -p /mnt/efs/filipe/var/www/html
mount -t efs fs-0acff854dd9917f5c.efs.us-east-1.amazonaws.com:/ /mnt/efs
chown ec2-user:ec2-user /mnt/efs

echo "fs-0acff854dd9917f5c.efs.us-east-1.amazonaws.com:/ /mnt/efs nfs defaults 0 0" >> /etc/fstab

docker-compose -f /home/ec2-user/docker-compose.yml up -d