<h1> Atividade Docker PB Compass </h1>

> Projeto realizado por Filipe Gomes, estagiário em Cloud & DevSecOps na Compass UOL.

## Finalidade da Documentação 
Mostrar o passo a passo da atividade proposta.

## Requisitos da atividade

* Instalação e configuração do DOCKER ou CONTAINERD no host EC2;

* Utilizar a instalação via script de Start Instance (user_data.sh);

* Efetuar Deploy de uma aplicação Wordpress com container de aplicação e container database Mysql;

* Configuração da utilização do serviço EFS AWS para estáticos do container de aplicação Wordpress;

* configuração do serviço de Load Balancer AWS para a aplicação Wordpress.

## user_data.sh

```
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

``` 
* yum update -y irá atualizar o sistema operacional Amazon Linux para a versão mais recente.
  
* yum install -y docker instala o Docker no sistema.

* yum install -y amazon-efs-utils instala o utilitário Amazon Elastic File System (EFS) no sistema.

* systemctl start docker inicia o serviço Docker.

* configura o Docker para ser iniciado automaticamente quando a instância é iniciada.

* usermod -aG docker ec2-user adiciona o usuário "ec2-user" ao grupo "docker" para permitir que o usuário execute comandos do Docker sem a necessidade de privilégios de root.

* chkconfig docker on configura o Docker para ser iniciado automaticamente quando a instância é iniciada.

*  curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose baixa a versão mais recente do Docker Compose e o instala no sistema.

* chmod +x /usr/local/bin/docker-compose define as permissões de execução para o arquivo docker-compose baixado.

* mv /usr/local/bin/docker-compose /bin/docker-compose move o arquivo docker-compose baixado para a pasta /bin para que possa ser executado globalmente.

* curl -sL https://raw.githubusercontent.com/filipegomes11/Compass-Docker/main/docker-compose.yml --output /home/ec2-user/docker-compose.yml baixa o arquivo docker-compose.yml e irá salvá-lo em /home/ec2-user/docker-compose.yml.

* mkdir -p /mnt/efs/filipe/var/www/html cria uma pasta no ponto de montagem do EFS para armazenar arquivos da aplicação.

* mount -t efs fs-0acff854dd9917f5c.efs.us-east-1.amazonaws.com:/ /mnt/efs monta o EFS na pasta /mnt/efs.

* chown ec2-user:ec2-user /mnt/efs define o proprietário e o grupo da pasta do EFS como "ec2-user".

* echo "fs-0acff854dd9917f5c.efs.us-east-1.amazonaws.com:/ /mnt/efs nfs defaults 0 0" >> /etc/fstab adiciona uma entrada ao arquivo /etc/fstab para que o EFS seja montado automaticamente sempre que a instância é iniciada.

* docker-compose -f /home/ec2-user/docker-compose.yml up -d inicia os contêineres definidos no arquivo docker-compose.yml em segundo plano, para executar a aplicação.

## Instalação do MySQL e WordPress através do Docker compose

``` 
    version: '3.3'
    services:
    db:
        image: mysql:latest
        restart: always
        environment:
        TZ: America/Recife
        MYSQL_ROOT_PASSWORD: teste
        MYSQL_USER: teste
        MYSQL_PASSWORD: teste
        MYSQL_DATABASE: wordpress
        ports:
        - "3306:3306"
        networks:
        - wordpress-network
    
    wordpress:
        depends_on:
        - db
        image: wordpress:latest
        ports:
        - "80:80"
        restart: always
        volumes:
        - /mnt/efs/filipe-gomes/var/www/html:/var/www/html
        environment:
        TZ: America/Recife
        WORDPRESS_DB_HOST: db
        WORDPRESS_DB_NAME: wordpress
        WORDPRESS_DB_USER: teste
        WORDPRESS_DB_PASSWORD: teste
        networks:
        - wordpress-network

    networks:
    wordpress-network:
        driver: bridge

```

* O documento define 'db' como um servico que usa a imagem do MYSQL mais recente;

* A porta 3306 é exposta para permitir a conexão com o banco de dados MySQL fora do contêiner;

* 'db' é conectado a rede wordpress-network;

* O documento define 'wordpress' como um serviço que usa a imagem WordPress mais recente;

* A porta 80 é exposta para permitir a conexão com o WordPress fora do contêiner;

* Um volume é definido para montagem do "/var/www/html" em uma pasta do Elastic File System (EFS);

* 'db' e 'wordpress' são conectados à mesma rede para que possam se comunicar.


## Próximo passo - AWS

1. Crie um bastion host. Para isso execute uma instância EC2 com uma subnet pública; 
2. Configure a porta 22 para que esteja aberta;
3. Crie outra instância, mas dessa vez privada;
4. Na criação da instância privada, cole o user_data.sh no local de inserir o user data na AWS;
5. Acesse a instância pública por SSH;
6. Dentro da instância pública, acesse a instância privada; 
7. Verifique se o user-data está funcionando e instale o que for necessário;
8. Crie um target group;
9. Crie um Load Balancer. No projeto foi utilizado um Application Load Balancer;
10. Copie o DNS do load balancer, cole e pesquise. Se a tela do WordPress aparecer, tudo está funcionando.

## Feito por Filipe Gomes.










