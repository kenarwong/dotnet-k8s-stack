[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
![License][license-shield]



<!-- PROJECT LOGO -->
<br />
<p align="center">
  <h3 align="center">A .NET Core Kubernetes Stack</h3>

  <p align="center">
    This proof-of-concept demonstrates a 3-tier .NET Core and MSSQL Kubernetes-based application.  Currently, built with Azure Cloud resources and Azure Kubernetes Service (AKS), but with intentions to eventually become cloud-agnostic.  
    <!-- <br />
    <a href="https://github.com/kenarwong/dotnet-k8s-stack"><strong>Explore the docs »</strong></a> -->
    <br />
    <br />
    <!--<a href="https://github.com/kenarwong/dotnet-k8s-stack">View Demo</a>
    · -->
    <a href="https://github.com/kenarwong/dotnet-k8s-stack/issues">Report Bug</a>
    ·
    <a href="https://github.com/kenarwong/dotnet-k8s-stack/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
## Table of Contents

* [About the Project](#about-the-project)
  * [Features](#features)
* [Getting Started](#getting-started)
  * [Domain Name](#domain-name)
  * [Cloud](#cloud)
    * [Azure](#azure)
  * [Trigger a Deployment](#trigger-a-deployment)
  * [Let's Encrypt Environments](#lets-encrypt-environments)
* [Usage](#usage)
  * [Tools](#tools)
* [Roadmap](#roadmap)
* [Contributing](#contributing)
* [Contact](#contact)
* [Acknowledgements](#acknowledgements)
<!-- * [License](#license) -->


<!-- ABOUT THE PROJECT -->
## About The Project

<!-- [![Product Name Screen Shot][product-screenshot]](https://example.com) -->

The intention of this project is to perform a deep-dive into the features (and limitations) that Kubernetes has to offer, as well as using open-source projects to make a real-world implementation possible.  The project is constructed on Azure Cloud infrastructure and Azure Kubernetes Service (AKS), but hopefully can be extended to other cloud providers and/or a self-managed cluster.

In the spirit of Kubernetes, objectives are:
* A software-defined system that is extensively captured by source control
* Automated turnkey deployment, limiting manual intervention if possible
* Declarative infrastructure provisioning and application management
* Built-in security, reliability, and monitoring
* Interchangable configuration across environments
* Ability to scale without sacrificing automation and management capabilities

Please view these diagrams to see visual representations of the project:
* [Infrastructure][infrastructure-diagram]
* [DevOps][devops-diagram]

<!-- FEATURES -->
## Features

This proof-of-concept currently includes:
* Web (Angular/.NET Core), API (.NET Core), and Data (MSSQL) tiers
* Private Docker registry (Azure Container Registry)
* Persistent data storage (Azure Disk)
* Public IP and DNS (Azure DNS)
* Name-based virtual hosting (NGINX Ingress)
* Let's Encrypt certificate management (cert-manager)
* Network security policies (Calico)
* Infrastructure state management (Terraform)
* Kubernetes application management (Helm)
* Build and deployment workflow (GitHub Actions)

More features to come...

<!-- GETTING STARTED -->
## Getting Started

To get started, fork the project into your own GitHub repository.  Then, you will need a public domain and a cloud environment.

### Domain Name

Acquire a public domain name.  The deployment will create DNS records on name servers, which we will setup in the public domain to delegate to those name servers.

### Cloud

Below are instructions on how to set up a cloud environment for different cloud providers.

#### Azure

To begin on Azure, you will need a [subscription][azure-site] and sufficient privileges to create several [service principals](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals#service-principal-object).  The project uses a total of 3 service principals with different roles and responsibilities.  Separating the service principals in this manner satisfies the principle of least privilege.

1. The first service principal will require a Contributor role to the subscription.  This service principal will only be used to provision infrastructure resources during deployment to Azure.  To create this service principal with Azure CLI:
```sh
az ad sp create-for-rbac --name "myAppProvisioner" --role contributor \
                         --scopes /subscriptions/{subscription-id} \
                         --sdk-auth
```
Save the output of this command.

2. Two more service principals will be required.  One will be used for Kubernetes operations, and the other for Let's Encrypt DNS challenges.  Only create the service principals without any role assignments.  During deployment, the roles will automatically be given specific scope to resources that will be created.  To create these service principals with Azure CLI:
```sh
az ad sp create-for-rbac --name "myAppKubernetes" --skip-assignment
az ad sp create-for-rbac --name "myAppCertificateManager" --skip-assignment
```
Save the output of these commands.  You will also need query for the object IDs for these service principals, since they are not provided by the default output.  To retrieve the object ID, supply the following Azure CLI command with the `appId` values from the above outputs:
```sh
az ad sp show --id <appId> --query objectId
```

3. In your repository's Settings > Secrets tab.  Enter the following secret values.

| Secret Name                | Description                                                                            |
|----------------------------|----------------------------------------------------------------------------------------|
| ARM_CLIENT_ID              | The client ID from step 1                                                              |
| ARM_CLIENT_SECRET          | The client secret from step 1                                                          |
| AZURE_CREDENTIALS          | The entire JSON object from step 1                                                     |
| AZURE_SUBSCRIPTION_ID      | The subscription ID from step 1                                                        |
| AZURE_TENANT_ID            | The tenant ID from step 1                                                              |
| CERT_MANAGER_CLIENT_ID     | The client ID for the certificate manager service principal from step 2                |
| CERT_MANAGER_CLIENT_SECRET | The client secret (password) for the certificate manager service principal from step 2 |
| CERT_MANAGER_OBJECT_ID     | The object ID for the certificate manager service principal from step 2                |
| CERT_REGISTRATION_EMAIL    | An email to be used when registering your Let's Encrypt SSL certificate                |
| K8S_CLIENT_ID              | The client ID for the kubernetes service principal from step 2                         |
| K8S_CLIENT_SECRET          | The client secret (password) for the kubernetes service principal from step 2          |
| K8s_OBJECT_ID              | The object ID for the kubernetes service principal from step 2                         |
| PUBLIC_DOMAIN_NAME         | Your public domain name (e.g. example.com)                                             |

### Trigger a Deployment
 
1. Clone the repo
```sh
git clone https://github.com/<username>/dotnet-k8s-stack.git
```

2. Edit the following values in the configuration files in the [config folder][config-folder]:

| Environmental Variable       | Description                                                                              |
|------------------------------|------------------------------------------------------------------------------------------|
| LOCATION                     | The Azure data center location for your resources                                        |
| TERRAFORM_BACKEND_GROUP_NAME | The resource group name for the terraform state file.                                    |
| STORAGE_ACCOUNT_NAME         | The storage account for the terraform state file.  Only alphanumeric characters allowed. |
| GROUP_NAME                   | The resource group name for this project's resources.                                    |
| CLUSTER_NAME                 | The name of the Kubernetes cluster.                                                      |
| ACR_NAME                     | The name of the Azure Container Repository.  Only alphanumeric characters allowed.       |

3. Github Actions is configured with `workflow_dispatch`.  See `on.workflow_dispatch` at the top of the [workflow][workflow-yaml] file.  Now you should be able to trigger a deployment from the Actions tab.  When running the workflow, select the appropriate branch and provide an <em>Environment</em> variable.  Acceptable values are the names of the files in the [config folder][config-folder] (e.g. `dev`, `prod`).
    * **Note** The `dev` is configured to uses the Let's Encrypt Staging environment, and `prod` uses production. Refer to [Let's Encrypt Environments](#lets-encrypt-environments) for more information.


4. NGINX Ingress uses an Azure Public IP and Azure DNS to receive traffic. So, you will have to set your public domain to use Azure domain name servers. In the completed workflow, navigate through the logs to the `terraform output` step in the `infrastructure` job.  Here terraform will output the Azure domain name servers that were created.  Set the name servers of your public domain to use these domain servers.

### Let's Encrypt Environments
Let's Encrypt [rate limits][lets-encrypt-rate-limits] its production certificates, so it's not advisable to repeatedly deploy production code because it will attempt to re-issue production certificates. You'll most likely encounter an error after requesting too many certificate and will have to wait a week before you can request another. During development, use the `dev` configuration which uses the [Let's Encrypt Staging environment][lets-encrypt-staging-environment]. The Staging environment has much higher rate limits, but issues a dummy certificate that isn't actually issued from a trusted authority. You can still navigate to your domain, but you will have to manually accept the certificates in your browser for both the domain and the api virtual host for the site to work. (The application makes calls to the standalone api virtual host for some of its features.) For example, if your domain is `domain.com` you will have to manually navigate to `domain.com` and `api.domain.com` in your browser and accept each certificate.

<!-- USAGE EXAMPLES -->
## Usage

<!-- Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources.

_For more examples, please refer to the [Documentation](https://example.com)_

-->

### Tools

You will need the following tools to work with this project:
* [az](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
* [dotnet](https://docs.microsoft.com/en-us/dotnet/core/install)
* [docker](https://www.docker.com/get-started)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl)
* [helm](https://helm.sh/docs/intro/install)
* [terraform](https://www.terraform.io/downloads.html)

<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/kenarwong/dotnet-k8s-stack/issues) for a list of proposed features (and known issues).



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



<!-- CONTACT -->
## Contact

Project Link: [https://github.com/kenarwong/dotnet-k8s-stack](https://github.com/kenarwong/dotnet-k8s-stack)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements

* [Kubernetes](https://kubernetes.io/)
* [Azure AKS](https://docs.microsoft.com/en-us/azure/aks/)
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/)
* [.NET Core CLI](https://docs.microsoft.com/en-us/dotnet/core/tools/)
* [Angular](https://angular.io/)
* [Terraform](https://www.terraform.io/)
* [Helm](https://helm.sh/)
* [NGINX Ingress](https://kubernetes.github.io/ingress-nginx/)
* [Let's Encrypt](https://letsencrypt.org/)
* [cert-manager](https://cert-manager.io/)
* [Calico](https://www.projectcalico.org/)
* [Best README Template](https://github.com/othneildrew/Best-README-Template)


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/kenarwong/dotnet-k8s-stack
[contributors-url]: https://github.com/kenarwong/dotnet-k8s-stack/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/kenarwong/dotnet-k8s-stack
[forks-url]: https://github.com/kenarwong/dotnet-k8s-stack/network/members
[stars-shield]: https://img.shields.io/github/stars/kenarwong/dotnet-k8s-stack
[stars-url]: https://github.com/kenarwong/dotnet-k8s-stack/stargazers
[issues-shield]: https://img.shields.io/github/issues/kenarwong/dotnet-k8s-stack
[issues-url]: https://github.com/kenarwong/dotnet-k8s-stack/issues
[license-shield]: https://img.shields.io/github/license/kenarwong/dotnet-k8s-stack
[product-screenshot]: images/screenshot.png
[devops-diagram]: doc/diagrams/devops.jpg
[infrastructure-diagram]: doc/diagrams/infrastructure.jpg
[config-folder]: config
[workflow-yaml]: .github/workflows/main.yaml
[azure-site]: https://azure.microsoft.com
[lets-encrypt-rate-limits]: https://letsencrypt.org/docs/rate-limits
[lets-encrypt-staging-environment]: https://letsencrypt.org/docs/staging-environment
