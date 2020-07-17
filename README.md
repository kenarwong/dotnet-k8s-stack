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
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
* [Usage](#usage)
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

To get a local copy up and running follow these simple steps.

### Prerequisites

You will need several tools to work with this project:
* [az](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
* [dotnet](https://docs.microsoft.com/en-us/dotnet/core/install)
* [docker](https://www.docker.com/get-started)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl)
* [helm](https://helm.sh/docs/intro/install)
* [terraform](https://www.terraform.io/downloads.html)

To begin on Azure, you will need a [subscription](https://azure.microsoft.com) and sufficient privileges to create several [service principals](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals#service-principal-object).  The project uses a total of 3 service principals with different roles and responsibilities.  Separating the service principals in this manner satisfies the principle of least privilege.

* The first service principal will require a Contributor role to the subscription.  This service principal will only be used to provision infrastructure resources during deployment to Azure.  To create this service principal with Azure CLI:
```sh
az ad sp create-for-rbac --name "myAppProvisioner" --role contributor \
                         --scopes /subscriptions/{subscription-id} \
                         --sdk-auth
```
Save the output of this command for later.

* Next, two more service principals will be required.  One will be used for Kubernetes operations, and the other for Let's Encrypt DNS challenges.  We only need to create the service principals without any role assignments.  The roles will automatically be given specific scope to resources that will be created during provisioning.  To create these service principals with Azure CLI:
```sh
az ad sp create-for-rbac --name "myAppKubernetes" --skip-assignment
az ad sp create-for-rbac --name "myAppCertificateManager" --skip-assignment
```
Save the output of these commands for later.

### Installation
 
1. Clone the repo
```sh
git clone https://github.com/kenarwong/dotnet-k8s-stack.git
```
2. 
```sh

```



<!-- USAGE EXAMPLES -->
## Usage

<!-- Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources.

_For more examples, please refer to the [Documentation](https://example.com)_

-->

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
