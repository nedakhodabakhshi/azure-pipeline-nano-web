
# 🚀 Azure Pipeline: Deploy a Nano Website with Apache, Docker & ACI

This project demonstrates how to fully automate the deployment of a static Nano-style web dashboard using:

- 🐳 Docker + Apache
- ☁️ Azure Container Registry (ACR)
- 🟦 Azure Container Instances (ACI)
- 🔁 Azure DevOps Pipelines (CI/CD)
- ⚙️ Dynamic content download with `wget`

---

## 📁 Project Structure

```plaintext
azure-pipeline-nano-web/
├── Dockerfile                # Apache + unzip + wget-based installer
├── azure-pipelines.yml       # Full CI/CD automation pipeline
├── images/                   # Screenshots (for GitHub)
│   ├── 01-Resource-Group.png
│   ├── 02-Service-Connection.png
│   ├── 03-Azure-Pipeline.png
│   ├── 04-Azure-Pipeline-job.png
│   ├── 05-Container-Registry.png
│   ├── 06-Container-instance.png
│   ├── 07-Container-FQDN.png
│   ├── Container-Instance.png
│   ├── 08-Web-App.png
├── README.md                 # This file
```

---

## 🌐 Live URL (after deployment)

```bash
http://nano-web-instance123.centralus.azurecontainer.io
```

---

## 🔨 What This Project Does

✅ Automates everything from build to deploy:

1. Builds a Docker image using Apache
2. Downloads site ZIP using `wget` (via ARG)
3. Pushes the image to ACR (`myrepo126`)
4. Deploys the container to Azure Container Instances (`nano-container`)
5. Publishes it with a public DNS

---

## 📦 Dockerfile Logic

```Dockerfile
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
```

- Uses Apache (httpd)
- Downloads: https://www.tooplate.com/zip-templates/2108_dashboard.zip
- Unzips into Apache's serving folder

---

## 🔁 azure-pipelines.yml

Automates every step:
```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

variables:
  resourceGroup: 'myResourceGroup'
  location: 'centralus'
  acrName: 'myrepo126'
  imageName: 'nano-website-apache'
  containerName: 'nano-container'
  dnsName: 'nano-web-instance123'
  zipUrl: 'https://www.tooplate.com/zip-templates/2108_dashboard.zip'

steps:
- task: AzureCLI@2
  inputs:
    azureSubscription: 'Azure-RM-Connection'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      echo "✅ Starting automated deployment..."

      echo "➡️ Enabling admin access on ACR..."
      az acr update -n ${{ variables.acrName }} --admin-enabled true

      echo "➡️ Creating ACR (if not exists)..."
      az acr show --name ${{ variables.acrName }} --resource-group ${{ variables.resourceGroup }} ||       az acr create         --resource-group ${{ variables.resourceGroup }}         --name ${{ variables.acrName }}         --sku Basic         --admin-enabled true

      echo "➡️ Login to ACR..."
      az acr login --name ${{ variables.acrName }}

      echo "➡️ Build Docker image with wget-based web content..."
      docker build --build-arg ZIP_URL=${{ variables.zipUrl }} -t ${{ variables.imageName }} .

      echo "➡️ Tag & push image to ACR..."
      docker tag ${{ variables.imageName }} ${{ variables.acrName }}.azurecr.io/${{ variables.imageName }}:latest
      docker push ${{ variables.acrName }}.azurecr.io/${{ variables.imageName }}:latest

      echo "➡️ Get ACR credentials..."
      ACR_USERNAME=$(az acr credential show -n ${{ variables.acrName }} --query username -o tsv)
      ACR_PASSWORD=$(az acr credential show -n ${{ variables.acrName }} --query passwords[0].value -o tsv)

      echo "➡️ Delete existing container if it exists..."
      az container delete --name ${{ variables.containerName }} --resource-group ${{ variables.resourceGroup }} --yes || true

      echo "➡️ Create container instance with ACR credentials..."
      az container create         --resource-group ${{ variables.resourceGroup }}         --name ${{ variables.containerName }}         --image ${{ variables.acrName }}.azurecr.io/${{ variables.imageName }}:latest         --dns-name-label ${{ variables.dnsName }}         --ports 80         --os-type Linux         --cpu 1         --memory 1.5         --registry-login-server ${{ variables.acrName }}.azurecr.io         --registry-username $ACR_USERNAME         --registry-password $ACR_PASSWORD

      echo "✅ Deployment complete. Access the app at:"
      echo "🌐 http://${{ variables.dnsName }}.centralus.azurecontainer.io"
  displayName: 'Full CI/CD: Build Docker Image, Push to ACR, Deploy to ACI'

---

## ✅ Prerequisites

- Azure DevOps account & project
- Azure subscription
- Azure service connection (`Azure-RM-Connection`)
- This GitHub repo connected to a pipeline


> ⭐ If this repo helped you, feel free to star it and share!
