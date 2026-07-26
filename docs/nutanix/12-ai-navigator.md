# AI Navigator and MCP Server

## AI Navigator

- You have a Pro or Ultimate license for DKP version 2.6.0 or later, or NKP
  version 2.12 or later.
- You accepted the user agreement.
- Your environment has internet access.

Core Components

- Retrieval-augmented generation:

The retrieval-augmented generation (RAG) engine sources relevant documents,
enriches queries with contextual information, and interfaces with large
language models (LLMs) to generate responses.

- NKP MCP Server (optional):

The NKP MCP Server injects cluster-specific data into user queries and
enriches the context for the RAG component to produce accurate and relevant
responses based on the target cluster's characteristics.

Deployment Models

- Default installation:

AI Navigator app deploys on a NKP management cluster and integrates with the
Nutanix-managed Azure OpenAI Service through AI Navigator RAG service.

Figure 27: AI Navigator Architecture with Azure OpenAI Through Nutanix

In the default deployment, the AI Navigator app runs on the NKP management
cluster. Requests move from the app to a local AI Navigator RAG service inside
the cluster. The RAG service connects to the Nutanix-managed Azure OpenAI
Service for model inference. The figure summarizes how the management cluster,
the external RAG service, and Azure OpenAI connect.

- Your Azure OpenAI Service:

You can configure the AI Navigator app component to use your own instance of
Azure OpenAI Service, providing greater control over data residency,
compliance, and cost optimization.

In this configuration, the overall system architecture remains largely
consistent. However, you configure the RAG component to query your language
model endpoint instead of the default Nutanix-managed service. The bring-your-
own-model (BYOM) approach helps you tailor the AI capabilities to your
specific operational and governance requirements.

When you use your own Azure OpenAI Service, the AI Navigator app and the RAG
workload run on the management cluster. The RAG component sends inference
traffic to your Azure OpenAI endpoint instead of the Nutanix-managed service.
The figure summarizes how your requests pass through the app and local RAG
tier to your Azure OpenAI instance for BYOM, data residency, and governance
requirements.

## AI Navigator installation

AI Navigator runs with licensed NKP, Pro or Ultimate, and internet. At first
install choose inclusion; NKP installs it by default with those licenses.

To use AI Navigator, log in to a licensed Nutanix Kubernetes Platform (NKP)
environment.

When you install NKP for the first time, you choose whether to include AI
Navigator.

To deploy AI Navigator, follow the installation procedures for your
infrastructure provider. NKP installs AI Navigator by default when your
deployment uses a Pro or Ultimate license.

## Disabling AI Navigator

Disable AI Navigator app using the UI or CLI.

About this task

Disabling AI Navigator removes the application and its resources from your NKP
cluster.

Disable AI Navigator using one of the following methods.

Procedure

1. From the NKP UI, go to the Management Cluster Workspace and click
   Applications > View Details > Disable.
2. From the CLI, on the NKP management cluster, run the following command.

```bash
kubectl delete appdeployment ai-navigator-app -n kommander
```

## Accessing AI Navigator

Access AI Navigator from the NKP user interface to use AI-powered assistance
for managing your environment.

About this task

> **Note: AI Navigator is not available in air-gapped NKP environments.**

AI Navigator is available by default in internet-connected NKP environments
with Pro or Ultimate licenses.

To access AI Navigator, follow these steps:

Procedure

1. Log in to the Nutanix Kubernetes Platform (NKP) user interface.
2. Click the AI Navigator icon in the lower-right corner of the dashboard.

Figure 28: AI Navigator Icon in the NKP Dashboard 3. Review and accept the
user agreement to use AI Navigator.

AI Navigator uses AI models trained on Nutanix product documentation and the
Nutanix Support knowledge base to provide real-time, interactive assistance
for a wide range of queries. A Pro or Ultimate license with DKP 2.6.0 or later
is required.

When you open AI Navigator for the first time, the user agreement appears.
Click Yes, I agree to accept and continue. If you click No, not now, the AI
Navigator window closes and you cannot use AI Navigator.

To include cluster live data in AI Navigator responses, activate the NKP MCP
Server. For more information, see NKP MCP Server Overview on page 1104.

```yaml
Note: AI Navigator maintains your query history for the duration of your browser session, even if you close the AI
Navigator window.
```

## AI Navigator Guidelines

General usage guidelines for AI Navigator. As with all AI engines, you should
NOT enter sensitive information, including:

- Full names, addresses, or other personally identifying information (PII)
- Technical secrets:
- Actual server names
- Real IP addresses
- Private keys
- Access tokens
- Any other technical details that might be useful to bad actors
- Government ID numbers
- Corporate, financial, or investment information
- Company Confidential information
- Company credentials, including actual usernames, or passwords
- Secured or classified information

```yaml
Note: Your organization might have specific rules about the prompts that you enter. Refer to your organization's
guidelines for additional information.
```

### AI Navigator Query Guidelines

Prompt engineering is the practice of crafting precise queries to retrieve
accurate responses from a chatbot. Several techniques that improve results
with large language model chatbots also apply to AI Navigator.

When you create a prompt, the chatbot breaks your entry into discrete parts to
search its model. The more precise your prompt, the more relevant the
response.

Fine-tuning adjusts the parameters and data that a chatbot model searches to
improve response accuracy. NKP fine-tunes the AI Navigator model with NKP
documentation, Kubernetes documentation, and the NKP Support Knowledge Base to
keep answers focused and relevant.

What Goes in a Prompt

You can include straight text, inline code snippets such as kubectl commands,
and code block snippets, within a limit of 4,096 characters.

AI Navigator maintains your query history for the duration of your browser
session, whether you close the AI Navigator panel or keep it open..

- Plain text: Use standard text to describe your question or provide context
  for AI Navigator.
- Inline commands or code snippets: Use single backtick marks to include a
  word, phrase, or command. For example: What are the parameters I can use
  with the `nkp create cluster` command?
- Code blocks: Use a triple backtick to open a code block for entry, as in
  many chat and collaboration applications. For example:

```bash
Where do I need to use this code:
```

nkp create cluster aws \
--http-proxy=x.x.x.1
--https-proxy=x.x.x.2

````bash

## NKP MCP Server Overview

NKP MCP Server provides AI Navigator with real-time, identity-aware access to Kubernetes cluster resources for context-based operational responses.

NKP MCP Server is a Model Context Protocol (MCP)-compliant server that provides AI Navigator with real-time access to Kubernetes cluster state. MCP is an open standard that defines how AI assistants discover and invoke external tools. NKP MCP Server exposes cluster operations, such as listing pods and inspecting resources, as MCP tools that AI Navigator can invoke on demand.

When you ask a cluster question in AI Navigator, the request is sent to NKP MCP Server. The server queries the Kubernetes API and returns structured data that AI Navigator uses to generate the response. This workflow grounds AI Navigator responses in live cluster data instead of static documentation or pretrained model knowledge.

NKP MCP Server helps retrieve operational details such as cluster etcd version, container image, behavior of a specific CronJob, and Insights version in use.

NKP MCP Server enforces Kubernetes RBAC based on user identity. When a user interacts with AI Navigator, the server passes that identity to the Kubernetes API, and Kubernetes RBAC evaluates each request against the roles and permissions already defined in the cluster.

NKP MCP Server is available for internet-connected environments with a Pro or Ultimate license.

For more information about data collection and processing, see AI Navigator Data Privacy on page 1105.
```yaml
Warning: To support security requirements in public sector, defense, and
network-restricted environments, AI
Navigator is not available for air-gapped implementations.
```bash

NKP MCP Server Infrastructure

### NKP MCP Server Activation

Prerequisite :

Ensure Artificial Intelligence (AI) Navigator is enabled.

Enable the NKP MCP Server

Activate the NKP MCP Server application on your management cluster. For more information, see Activating an Application Using the UI.

> **Note:**

- If you have an ultimate license, select the management cluster workspace before deploying the NKP MCP Server.
- After the NKP MCP Server is enabled, it takes up to one minute for the AI Navigator agent to discover and load the available tools.

### Disabling NKP MCP Server

About this task

After you uninstall the NKP MCP Server, AI Navigator responses no longer include cluster-specific data such as configuration details and health status. You can reinstall the application at any time from the NKP UI. To uninstall the NKP MCP Server, follow these steps:

Procedure

Uninstall the NKP MCP Server application like any other application as explained in Ultimate: Disabling an Application Using the UI on page 336.

### AI Navigator Data Privacy

When the NKP MCP Server is on, AI Navigator can combine your prompts with live Kubernetes metadata and status from the management cluster. Use the sections that follow to learn how that information moves, what enters processing, why it is used, and what you can change.

Data Flow During Queries

With the NKP MCP Server enabled, each exchange routes prompt and cluster context through the AI service without retaining content for model training in the ways described for the supporting cloud offering. For more information, see What Happens to My Data During an AI Navigator Query if the NKP MCP Server is Enabled? on page 1106.

Types of Data Collected and Processed

AI Navigator pulls object metadata and status (for example nodes, pods, services, and related workload detail) needed to ground answers in current cluster state. For more information, see Types of Data Collected and Processed on page 1106.

Cluster Data Processing

The NKP MCP Server forwards only the cluster context required for your question so the AI service can return a relevant answer, in line with Nutanix and contractual privacy requirements. For more information, see Cluster Data Processing on page 1107.

Data Storage and Management

You can turn the NKP MCP Server off to exclude live cluster data from responses. Other chatbot processing and retention behaviors are not end-user configurable. For more information, see Data Storage and Management on page 1107.

#### What Happens to My Data During an AI Navigator Query if the NKP MCP Server is Enabled?

NKP does not store data related to your queries, pro clusters, or management clusters. The Azure OpenAI Service also does not store your data. OpenAI, Nutanix, and other customers cannot access your data, and the OpenAI model does not use your data for training. For more information, see Data, privacy, and security for Azure Direct Models in Microsoft Foundry.

AI Navigator with NKP MCP Server enabled stores query-related data directly in your environment. The following steps describe the data flow during a query:

1. You make a query requesting information related to your cluster, documentation, or both. 2. AI Navigator sends your
query to the Azure OpenAI Service, which determines the appropriate action based on the question querying live cluster
data, searching documentation, or both for troubleshooting scenarios. 3. For cluster data questions, the Azure OpenAI
Service instructs the agent to retrieve information from the NKP MCP Server. The NKP MCP Server queries the Kubernetes
API on your management cluster in real time, applying smart field filtering to return only the relevant data. Your
identity is forwarded so that Kubernetes RBAC policies are enforced. 4. For documentation questions, the agent searches
the vector store to retrieve relevant NKP, Kubernetes, Flux, or Cluster API documentation. 5. The Azure OpenAI Service
synthesizes the results live cluster state, documentation context, or both into a single answer to your query.

#### Types of Data Collected and Processed

AI Navigator collects the following types of data:

- nodes
- pods
- services
- events
- endpoints
- deployments
- statefulsets
- daemonsets
- namespaces
- ingresses
- jobs
- cronjobs
- helm.toolkit.fluxcd.io/helmreleases

#### Cluster Data Processing

We prioritize your data's privacy and security. When you enable this feature, any potentially sensitive information from your Management cluster will be securely transmitted and processed by our trusted cloud service provider, Azure OpenAI. This data is used exclusively to add additional context to your queries to provide to the AI Navigator service. We adhere to strict data protection and privacy standards, ensuring responsible handling of your information.

Use of the AI Navigator chatbot with the NKP MCP Server is governed by the terms of the Nutanix License and Service Agreement, the Nutanix privacy policy and the Azure OpenAI privacy policy. For more information, see Data Privacy in Azure.

#### Data Storage and Management

You cannot modify the way the chatbot processes or stores data.

## Connect AI Navigator with Your Own Azure OpenAI Service

AI Navigator can use your Azure OpenAI Service so LLM inference traffic stays within your Azure tenant instead of routing through Nutanix production services.

By default, AI Navigator routes queries through a Nutanix-managed Azure OpenAI Service, so no additional configuration is required. If your organization requires data to remain within its own Azure tenant, you can configure AI Navigator RAG to use your own Azure OpenAI Service instead.

In this configuration, the AI Navigator RAG component runs directly on your NKP management cluster and connects to your
Azure OpenAI deployment for both the conversational model and the embedding model. To set this up, create an Azure
OpenAI Service resource in your Azure subscription, deploy the required chat model (for example, GPT-4o mini) and
embedding model (for example, text-embedding-ada-002), and then configure the AI Navigator RAG Helm chart with your
Azure OpenAI endpoint, deployment names, API version, and API key.

With this setup, all LLM inference traffic stays within your Azure tenant. Query data, documentation context, and cluster information retrieved by the NKP MCP Server are sent only to your Azure OpenAI endpoint and are never routed through Nutanix production services.

### Enterprise Azure OpenAI Endpoint Disclaimer

Your organization, not Nutanix, manages this endpoint to support AI-driven use cases. For more information, see Azure OpenAI endpoints.

By proceeding, you acknowledge and accept the following responsibilities.

- Endpoint security: Your organization must secure and manage its Azure OpenAI endpoint, including all configurations, access controls, and network protections.
- Credential management: Your organization must securely store, rotate as needed, and protect all API keys, tokens, and authentication credentials in accordance with your internal security policies.
- Data governance: Your organization must ensure that all data transmitted through the endpoint complies with your data governance standards and applicable privacy regulations.
- Compliance and risk: Your organization must comply with Azure OpenAI's terms of use and any legal, regulatory, or contractual obligations related to the use of Azure OpenAI services.
- Costs: Your organization must bear all costs associated with Azure OpenAI endpoint usage, including charges for token usage.

AI Navigator RAG does not persist or monitor your Azure OpenAI endpoint credentials or transmitted data. You can disable the Azure OpenAI endpoint at any time by deleting the deployment that you created. For more information, see Azure OpenAI endpoints and Azure OpenAI deployments. If you do not agree to these terms, do not proceed with endpoint configuration and the AI Navigator RAG installation.

### Configuring AI Navigator App to use Custom Azure OpenAI Service

Prerequisites

- Ensure you have a deployment and endpoint for an Azure OpenAI Service.
- Ensure that you have the following details from the Azure OpenAI Service deployment:
- Azure OpenAI API key
- Model name
- Completion model deployment name
- Embeddings model name
- Embeddings model deployment name
- API endpoint
- API version

The 2.18 release of AI Navigator is validated to work with the following:

- Model name: gpt-5o-mini
- Completion model name: gpt-5o-mini
- Embeddings model name: text-embedding-ada-002
- API version: 2024-10-21

Values other than these are not validated for use with AI Navigator.

AI Navigator App Configuration

To use your own Azure OpenAI service with the AI Navigator app to use, follow these steps:

1. Create a secret with the Azure OpenAI API key. 2. Reconfigure the AI Navigator app from the NKP UI to use a custom Azure OpenAI service.

#### Creating a Secret with Azure OpenAI API Key

About this task

Create a secret with Azure OpenAI API Key

Procedure

1. Open a terminal with access to the NKP management cluster.
2. Create the secret:

```bash
kubectl create secret generic ai-navigator-app-secrets -n kommander --from-
literal=OPENAI_API_KEY=$OPENAI_API_KEY
```bash

Replace $OPENAI_API_KEY with your Azure OpenAI API key.

#### Switch AI Navigator App to your own Azure OpenAI Service

About this task

Log in to the Nutanix Kubernetes Platform (NKP) user interface.

To edit the AI Navigator app, complete these steps:

Procedure

1. In the NKP user interface, click Management Cluster Workspace.
2. Click Applications.
3. In the Tools section, locate NKP AI Navigator.
4. Click the three-dots icon and click Edit.
5. Add the following configuration, replacing the placeholder values with your configuration values:

The YAML root key is llm.

```bash
llm:
apiType: azure
modelName: `<model name, for example, gpt-5o-mini>`
embeddingsModelName: `<embeddings model name, for example, text-embedding- ada-002>`
apiEndpoint: https://`<Azure OpenAI Service Name>`.openai.azure.com
openai:
modelDeploymentName: `<completion model deployment name, for example, gpt-5o-mini>`
embeddingsDeploymentName: `<embeddings model deployment name, for example, text- embedding-ada-002>`
embeddingsModelApiVersion: `<embeddings model API version, for example, "2024-10-21">`
chatModelApiVersion: `<completion model API version, for example, "2024-10-21">`
```bash

1. Click Save.

### Revert AI Navigator to the Nutanix-Managed Azure OpenAI Service

About this task

To restore the AI Navigator app, follow these steps:

Procedure

1. In the NKP UI, go to Management Cluster Workspace > Applications, edit NKP AI Navigator, and remove the custom llm configuration.
2. Delete the Kubernetes secret containing the Azure OpenAI API key.

#### Restore AI Navigator Configuration

About this task

After you restore the default configuration, the AI Navigator app uses only the default cloud-based model for query responses.

To restore the AI Navigator app configuration, follow these steps:

Procedure

1. In the NKP user interface, click Management Cluster Workspace.
2. Click Applications.
3. In the Tools section, locate NKP AI Navigator.
4. Click the more options (three dots) icon, and then click Edit.
5. Remove the llm section with your custom configuration.
6. Click Save.

#### Deleting the Secret with Azure OpenAI API Key

About this task

To delete the Azure OpenAI API key secret from NKP management cluster, follow these steps:

Procedure

1. Open a terminal with access to NKP management cluster.
2. Run the following command to delete the secret:

```bash
kubectl delete secret ai-navigator-app-secrets -n kommander
```bash
```
````
