# DevOps-project
# DevOps Project: CI/CD Pipeline with AWS, Terraform, Ansible, Docker, Jenkins, and Kubernetes

This project demonstrates the integration of DevOps tools to create a complete CI/CD pipeline. The pipeline provisions infrastructure using Terraform, configures Jenkins using Ansible, containerizes an application with Docker, and deploys it to a Kubernetes cluster using Jenkins.

## Project Workflow

1. **Provision Infrastructure with Terraform**: Launch an AWS EC2 instance for Jenkins.
2. **Configure Jenkins with Ansible**: Install Jenkins on the provisioned EC2 instance.
3. **Containerize the Application with Docker**: Build and push the Docker image to a registry.
4. **Deploy to Kubernetes**: Use Jenkins to deploy the application to a Kubernetes cluster.

---

## Prerequisites

- AWS account and access keys.
- SSH key pair for accessing AWS instances.
- Installed tools:
  - [Terraform](https://www.terraform.io/)
  - [Ansible](https://www.ansible.com/)
  - [Docker](https://www.docker.com/)
  - [Jenkins](https://www.jenkins.io/)
  - [Kubernetes CLI (kubectl)](https://kubernetes.io/docs/tasks/tools/)

---

## Project Setup

### Step 1: Provision AWS Infrastructure with Terraform

1. Create a `main.tf` file and define an AWS EC2 instance:

   ```hcl
   provider "aws" {
     region = "us-east-1"
   }

   resource "aws_instance" "jenkins_server" {
     ami           = "ami-0c55b159cbfafe1f0"
     instance_type = "t2.micro"
     key_name      = "your-key-pair"

     tags = {
       Name = "Jenkins-Server"
     }
   }

   output "instance_ip" {
     value = aws_instance.jenkins_server.public_ip
   }
   ```

2. Run the following commands to deploy the infrastructure:

   ```bash
   terraform init
   terraform apply
   ```

### Step 2: Configure Jenkins with Ansible

1. Create an Ansible inventory file:

   ```ini
   [jenkins]
   <EC2_INSTANCE_PUBLIC_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/your-key-pair.pem
   ```

2. Write a playbook (`jenkins-playbook.yml`) to install Jenkins:

   ```yaml
   - hosts: jenkins
     become: true
     tasks:
       - name: Install Java
         apt:
           name: openjdk-11-jdk
           state: present

       - name: Install Jenkins
         shell: |
           wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
           sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
           sudo apt update
           sudo apt install -y jenkins

       - name: Start Jenkins
         service:
           name: jenkins
           state: started
           enabled: true
   ```

3. Run the playbook:

   ```bash
   ansible-playbook -i inventory jenkins-playbook.yml
   ```

### Step 3: Containerize the Application with Docker

1. Write a `Dockerfile` in your application repository:

   ```dockerfile
   FROM python:3.9-slim
   WORKDIR /app
   COPY . /app
   RUN pip install -r requirements.txt
   CMD ["python", "app.py"]
   ```

2. Build and push the Docker image:

   ```bash
   docker build -t your-docker-repo/app:latest .
   docker push your-docker-repo/app:latest
   ```

### Step 4: Set Up Jenkins Pipeline

1. Create a `Jenkinsfile` in your repository:

   ```groovy
   pipeline {
       agent any
       stages {
           stage('Clone Repository') {
               steps {
                   git 'https://github.com/your-repo/app.git'
               }
           }
           stage('Build Docker Image') {
               steps {
                   script {
                       dockerImage = docker.build("your-docker-repo/app:latest")
                   }
               }
           }
           stage('Push Docker Image') {
               steps {
                   script {
                       docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials-id') {
                           dockerImage.push()
                       }
                   }
               }
           }
           stage('Deploy to Kubernetes') {
               steps {
                   kubernetesDeploy configs: 'k8s/deployment.yaml', kubeconfigId: 'kubeconfig-credentials-id'
               }
           }
       }
   }
   ```

2. Add credentials for Docker and Kubernetes in Jenkins.

### Step 5: Deploy to Kubernetes

1. Create Kubernetes deployment and service files:

   **Deployment (`deployment.yaml`):**

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: my-app
   spec:
     replicas: 2
     selector:
       matchLabels:
         app: my-app
     template:
       metadata:
         labels:
           app: my-app
       spec:
         containers:
         - name: my-app-container
           image: your-docker-repo/app:latest
           ports:
           - containerPort: 80
   ```

   **Service (`service.yaml`):**

   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: my-app-service
   spec:
       selector:
       app: my-app
     ports:
     - protocol: TCP
       port: 80
       targetPort: 80
     type: LoadBalancer
   ```

2. Use Jenkins to deploy the manifests.

---

## Conclusion

This project integrates multiple DevOps tools to create an automated CI/CD pipeline, demonstrating skills in provisioning, configuration management, containerization, and orchestration. Feel free to clone this repository, explore, and enhance it further.

---

## Author

[Piyush Bankhede](https://github.com/piyushbankhede)
