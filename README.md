# Agora Node Token Server
This is an example of a simple Node/Express server that generates tokens for Agora applications. 

### Run the server ###
- Install the dependencies
```node
npm install
```
- Create a copy of the `.env.example` file and save it as `.env`
- Add your Agora App ID and App Certificate:
```
APP_ID=ca123xxxxxx
APP_CERTIFICATE=12za123xxxxxx
```
You can obtain these values by selecting your project in the [Agora console projects section](https://console.agora.io/projects). Optionally, you can also define a port.

- Start the service
```node
npm start
```

## Endpoints ##

### Ping ###
**endpoint structure**
```
/ping
```
response:
``` 
{"message":"pong"} 
```

### RTC Token ###
The `rtc` token endpoint requires a `channelName`, `role` ('publisher' or 'audience'), `tokentype` ('uid' || 'userAccount') and the user's `uid` (type varies based on `tokentype` (example: `1000` for uid, `ekaansh` for userAccount). 
`(optional)` Pass an integer to represent the token lifetime in seconds.

**endpoint structure** 
```
/rtc/:channelName/:role/:tokentype/:uid/?expiry=
```

response:
``` 
{"rtcToken":" "} 
```

## RTM Token ##
The `rtm` token endpoint requires the user's `uid`. 
`(optional)` Pass an integer to represent the privelege lifetime in seconds.
**endpoint structure** 
```
/rtm/:uid/?expiry=
```

response:
``` 
{"rtmToken":" "} 
```

### Both Tokens ###
The `rte` token endpoint generates both the `rtc` and `rtm` tokens with a single request.
`(optional)` Pass an integer to represent the token lifetime in seconds.

**endpoint structure** 
```
/rte/:channelName/:role/:tokentype/:uid/?expiry=
```

response:
``` 
{
  "rtcToken":" ",
  "rtmToken":" " 
}
```

## How to Deploy

This application uses two GitHub Actions workflows for deployment to Kubernetes clusters. Both workflows are configured with default values for the QA environment.

### Available Workflows

#### 1. Docker Build and Deploy with Helm (`k8s-deployment-helm.yml`)

This workflow performs a complete build and deployment process:
- Builds the Docker image from the source code
- Pushes the image to the container registry
- Triggers the Helm chart deployment in the target Kubernetes cluster

**Use this workflow when:**
- You have code changes that need to be built and deployed
- You want to deploy a new version of the application

#### 2. Trigger Deploy (`trigger-deploy.yml`)

This workflow deploys an existing Docker image without building:
- Uses an existing image tag from the container registry
- Triggers the Helm chart deployment with the specified image tag

**Use this workflow when:**
- You want to redeploy an existing image (faster, no build step)
- You need to rollback to a previous image version
- You want to deploy an image that was already built

### Deployment Steps

#### Option A: Full Build and Deploy

1. **Push your changes** to the desired branch (typically `main` or your feature branch)

2. **Navigate to Actions** in the GitHub repository

3. **Select "Docker Build and Deploy with Helm"** workflow

4. **Click "Run workflow"** and fill in the parameters:

   - **Target deployment environment**: Select `nrd` or `mud` (default: `mud`)
   - **Key Vault ID**: The Key Vault identifier for secrets (default: `onland-metaverse-qa`)
   - **Secret Name**: Name of the Kubernetes secret containing application configuration (default: `api-agora-secrets`)
   - **Helm release name**: Name of the Helm release in Kubernetes (default: `qa`)
   - **Kubernetes namespace where the app is installed**: Target namespace in the cluster (default: `qa`)
   - **Image tag**: Choose `dev` or `latest` (default: `dev`)
   - **Branch to deploy**: Branch containing the code to deploy (default: `main`)
   - **Docker image name**: Name of the Docker image (default: `agora-node-token-server`)

5. **Click "Run workflow"** to start the deployment

#### Option B: Deploy Existing Image

1. **Navigate to Actions** in the GitHub repository

2. **Select "Trigger Deploy"** workflow

3. **Click "Run workflow"** and fill in the parameters:

   - **Target deployment environment**: Select `nrd` or `mud` (default: `mud`)
   - **Key Vault ID**: The Key Vault identifier for secrets (default: `onland-metaverse-qa`)
   - **Secret Name**: Name of the Kubernetes secret containing application configuration (default: `api-agora-secrets`)
   - **Helm release name**: Name of the Helm release in Kubernetes (default: `qa`)
   - **Kubernetes namespace where the app is installed**: Target namespace in the cluster (default: `qa`)
   - **Image tag**: The existing Docker image tag to deploy (default: `dev`)
   - **Branch to deploy**: Branch to use for the deployment trigger (default: `main`)
   - **Docker image name**: Name of the Docker image (default: `agora-node-token-server`)

4. **Click "Run workflow"** to start the deployment

### Input Parameters Explained

- **Target deployment environment**: The target environment identifier (`nrd` or `mud`). This determines which secrets and configuration are used.

- **Key Vault ID**: Identifier for the Key Vault where deployment secrets are stored. This is used to fetch credentials and configuration.

- **Secret Name**: The name of the Kubernetes secret that contains your application's environment variables and configuration.

- **Helm release name**: The name of the Helm release in your Kubernetes cluster. This identifies the deployment instance.

- **Kubernetes namespace where the app is installed**: The Kubernetes namespace where the application will be deployed or updated.

- **Image tag**: For build workflow, choose `dev` or `latest`. For trigger workflow, specify any existing image tag (e.g., commit SHA, version number).

- **Branch to deploy**: The Git branch containing the code to deploy. For the build workflow, this is the source branch. For the trigger workflow, this is used for workflow context.

- **Docker image name**: The name of the Docker image in the container registry (default: `agora-node-token-server`).

### Default Values

All workflows are pre-configured with default values for the **QA environment**:
- Environment: `mud`
- Key Vault ID: `onland-metaverse-qa`
- Release name: `qa`
- Namespace: `qa`
- Image name: `agora-node-token-server`

### Tenant-Specific Values

For deployments to different tenants or environments, please consult the **Deployment Matrix** for the correct values:

👉 **[View Deployment Matrix in Confluence](https://next-reality-digital-llc.atlassian.net/wiki/spaces/DevOps/pages/1339555842/How+to+Deploy+Applications)**

The Deployment Matrix contains all tenant-specific configuration values including:
- Key Vault IDs
- Secret names
- Release names
- Namespace names
- Environment identifiers

### Monitoring Deployment

After triggering a workflow:
1. Monitor the progress in the GitHub Actions tab
2. The workflow will show each step's status
3. Check the logs if any step fails
4. Once complete, verify the deployment in your Kubernetes cluster
