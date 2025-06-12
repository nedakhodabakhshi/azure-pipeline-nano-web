
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
│   ├── myrepo.png
│   ├── myimage.png
│   ├── Container-Instance.png
│   ├── WebApp.png
│   ├── ResourceGroup.png
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

ARG ZIP_URL

RUN apt-get update && \
    apt-get install -y wget unzip && \
    wget $ZIP_URL -O /tmp/site.zip && \
    unzip /tmp/site.zip -d /usr/local/apache2/htdocs/ && \
    rm /tmp/site.zip
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
      az acr show --name ${{ variables.acrName }} --resource-group ${{ variables.resourceGroup }} || \
      az acr create --resource-group ${{ variables.resourceGroup }} \
        --name ${{ variables.acrName }} --sku Basic --admin-enabled true

      az acr login --name ${{ variables.acrName }}

      docker build --build-arg ZIP_URL=${{ variables.zipUrl }} -t ${{ variables.imageName }} .
      docker tag ${{ variables.imageName }} ${{ variables.acrName }}.azurecr.io/${{ variables.imageName }}:latest
      docker push ${{ variables.acrName }}.azurecr.io/${{ variables.imageName }}:latest

      az container delete --name ${{ variables.containerName }} --resource-group ${{ variables.resourceGroup }} --yes || true

      az container create \
        --resource-group ${{ variables.resourceGroup }} \
        --name ${{ variables.containerName }} \
        --image ${{ variables.acrName }}.azurecr.io/${{ variables.imageName }}:latest \
        --dns-name-label ${{ variables.dnsName }} \
        --ports 80 \
        --os-type Linux \
        --cpu 1 \
        --memory 1.5
```

---

## 📸 Screenshots

| Preview | Description |
|--------|-------------|
| ![myrepo.png](images/myrepo.png) | Azure Container Registry |
| ![myimage.png](images/myimage.png) | Image pushed to ACR |
| ![Container-Instance.png](images/Container-Instance.png) | ACI deployment |
| ![WebApp.png](images/WebApp.png) | Live dashboard UI |
| ![ResourceGroup.png](images/ResourceGroup.png) | Resource group in Azure |

---

## ✅ Prerequisites

- Azure DevOps account & project
- Azure subscription
- Azure service connection (`Azure-RM-Connection`)
- This GitHub repo connected to a pipeline

---

## 💡 Next Steps

- 🔐 Enable HTTPS with a custom domain
- 📈 Add CI testing or linting
- ☸️ Move to AKS for container orchestration
- 🔄 Auto-cleanup or rollback steps

---

## 🙋 Maintained By

**Neda Khodabakhshi**  
📧 `khodabakhshi.neda@gmail.com`  
🔗 GitHub: [azure-pipeline-nano-web](https://github.com/nedakhodabakhshi/azure-pipeline-nano-web)

---

> ⭐ If this repo helped you, feel free to star it and share!