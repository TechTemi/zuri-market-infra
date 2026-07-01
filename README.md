\# Zuri Market Infrastructure DevSecOps Capstone



\## 1. Executive Summary



Zuri Market is an e-commerce platform for African artisan products, including handcrafted jewellery, Ankara fashion, organic skincare, and homeware. The company previously relied on a manually deployed Node.js application running on a single AWS EC2 instance.



That original setup created serious business and technical risks:



\* Secrets were handled unsafely.

\* Deployments were performed manually over SSH.

\* Environment variables were shared manually.

\* The application could not scale during peak traffic.

\* Infrastructure changes were not repeatable.



This DevSecOps Capstone rebuilds the Zuri Market deployment workflow using Docker, GitHub Actions, DockerHub, Terraform, AWS, AWS Secrets Manager, and k3s Kubernetes.



The target workflow is:



```text

Developer Push

→ GitHub Actions

→ Test

→ Security Scan

→ Docker Build

→ DockerHub

→ Terraform and AWS

→ k3s Deployment

→ Live Application

```



The final outcome is a secure, automated, repeatable deployment platform where:



\* Code changes trigger CI/CD automatically.

\* Docker images are built and pushed to DockerHub.

\* Infrastructure is provisioned with Terraform.

\* The application runs in Kubernetes/k3s.

\* Secrets are kept out of source code.

\* Evidence can be collected for capstone review.



This solution is close to production-ready because it introduces Infrastructure as Code, automated deployment, security gates, centralised secrets management, and Kubernetes-based runtime recovery.



Further production hardening is still recommended for high availability, observability, backup, and governance.



\---



\## 2. Pain Points and Solutions



| Pain Point                       | Impact                   | Solution Implemented                                              | Evidence                       |

| -------------------------------- | ------------------------ | ----------------------------------------------------------------- | ------------------------------ |

| Secret was committed to GitHub   | Credential exposure      | Use `.gitignore`, GitHub Actions Secrets, and AWS Secrets Manager | Repo search and AWS screenshot |

| Deployments were manual over SSH | Downtime and human error | Automate deployment with GitHub Actions                           | Successful workflow run        |

| Secrets were shared over Slack   | Poor secret control      | Use `.env`, `.env.example`, and managed secrets                   | GitHub Secrets screenshot      |

| App ran on one EC2 instance      | Poor scalability         | Deploy containers to k3s Kubernetes                               | `kubectl get pods` output      |

| AWS setup was manual             | Configuration drift      | Provision AWS with Terraform                                      | Terraform logs                 |

| No security gate existed         | Vulnerable releases      | Add dependency, image, and IaC scans                              | Pipeline scan logs             |

| README documentation was weak    | Slow onboarding          | Create root, frontend, and backend READMEs                        | README files in GitHub         |



Longer explanation: these solutions directly address the original Zuri Market risks by replacing manual work with automation, moving secrets into managed stores, and proving every delivery step with evidence.



\---



\## 3. Repository Map



```text

zuri-market-infra/

├── README.md

├── frontend/

│   └── README.md

├── backend/

│   └── README.md

├── terraform/

├── k8s/

├── docs/

│   └── images/

│       └── zuri-market-devsecops-architecture.png

└── .github/

&#x20;   └── workflows/

```



| Path                 | Purpose                                                     |

| -------------------- | ----------------------------------------------------------- |

| `README.md`          | Main infrastructure and DevSecOps documentation             |

| `frontend/README.md` | Frontend setup, build, test, and troubleshooting guide      |

| `backend/README.md`  | Backend setup, API, health check, and troubleshooting guide |

| `terraform/`         | AWS infrastructure code                                     |

| `k8s/`               | Kubernetes and k3s manifests                                |

| `docs/images/`       | Architecture image location                                 |

| `.github/workflows/` | GitHub Actions CI/CD workflows                              |



\---



\## 4. DevSecOps Architecture



!\[Zuri Market DevSecOps Architecture](docs/images/zuri-market-devsecops-architecture.png)



> Architecture image location: `docs/images/zuri-market-devsecops-architecture.png`

>

> This image is the provided architecture diagram and should be used as-is. It should not be redrawn, converted to SVG, or replaced with Mermaid.



The architecture is organised around five major lanes:



1\. Developer Machine

2\. CI/CD Pipeline

3\. DockerHub Registry

4\. AWS Infrastructure

5\. Runtime k3s Kubernetes Cluster



| Flow # | Source Lane         | Destination Lane   | Action                       | Tool Used                 | Output Produced             | Security Control               |

| ------ | ------------------- | ------------------ | ---------------------------- | ------------------------- | --------------------------- | ------------------------------ |

| 1      | Developer Machine   | GitHub Repository  | Push code to `main`          | Git                       | Updated source code         | `.env` ignored                 |

| 2      | GitHub Repository   | GitHub Actions     | Trigger pipeline             | GitHub Actions            | Workflow run                | Branch trigger                 |

| 3      | GitHub Actions      | Test Stage         | Run application tests        | npm                       | Test results                | Fail on error                  |

| 4      | GitHub Actions      | Security Stage     | Scan code and IaC            | Trivy, Checkov, tfsec     | Security report             | Fail on critical findings      |

| 5      | GitHub Actions      | Docker Build Stage | Build container images       | Docker                    | Frontend and backend images | Reproducible build             |

| 6      | GitHub Actions      | DockerHub          | Push tagged images           | DockerHub                 | Published images            | Protected registry credentials |

| 7      | GitHub Actions      | Terraform          | Validate infrastructure code | Terraform                 | Valid plan                  | IaC review                     |

| 8      | Terraform           | AWS Infrastructure | Provision AWS resources      | Terraform, AWS            | EC2, IAM, network           | Least privilege                |

| 9      | AWS Secrets Manager | k3s Cluster        | Provide runtime secrets      | AWS Secrets Manager       | Runtime secret values       | No hardcoded secrets           |

| 10     | GitHub Actions      | k3s Cluster        | Apply Kubernetes manifests   | kubectl                   | Updated workloads           | Secure kubeconfig              |

| 11     | k3s Cluster         | Application Pods   | Run containers               | Kubernetes                | Frontend and backend pods   | Self-healing workloads         |

| 12     | Kubernetes Service  | Users              | Expose application           | Service or Ingress        | Public access               | Controlled ports               |

| 13     | Engineer            | Evidence Store     | Capture proof                | CLI, browser, GitHub, AWS | Screenshots and logs        | Audit trail                    |



The developer writes code locally and pushes it to GitHub. GitHub Actions detects the push and starts the CI/CD workflow.



The pipeline runs tests, scans dependencies, checks container images, validates Terraform, builds Docker images, and pushes the images to DockerHub.



Terraform provisions the AWS infrastructure, including the EC2 instance, IAM access, security controls, and required networking.



k3s runs on the EC2 instance and hosts the frontend and backend workloads.



Secrets are not stored in source code. Pipeline credentials are stored in GitHub Actions Secrets. Runtime secrets are stored in AWS Secrets Manager and injected into the application at runtime.



\---



\## 5. Project Stages



| Stage # | Stage Name             | Purpose                    | Key Activities                     | Commands or Files                   | Expected Output           | Evidence                   |

| ------- | ---------------------- | -------------------------- | ---------------------------------- | ----------------------------------- | ------------------------- | -------------------------- |

| 1       | Repository Setup       | Prepare project structure  | Create folders and base files      | `git clone`, `mkdir`                | Clean repository          | Repository tree screenshot |

| 2       | Architecture Design    | Define delivery blueprint  | Add architecture image             | `docs/images/`                      | Diagram visible in README | README screenshot          |

| 3       | Terraform Setup        | Create infrastructure code | Write Terraform files              | `terraform/`                        | IaC files ready           | Terraform file screenshot  |

| 4       | Terraform Provisioning | Create AWS resources       | Run init, plan, and apply          | `terraform apply`                   | AWS resources created     | Terraform apply logs       |

| 5       | k3s Setup              | Prepare Kubernetes runtime | Install or verify k3s              | `kubectl get nodes`                 | Node is ready             | CLI screenshot             |

| 6       | Application Deployment | Run app workloads          | Apply manifests                    | `kubectl apply -f k8s/`             | Pods running              | Pod screenshot             |

| 7       | CI/CD Pipeline         | Automate release workflow  | Create workflow file               | `.github/workflows/`                | Pipeline ready            | GitHub Actions screenshot  |

| 8       | Security Scanning      | Add deployment gates       | Scan dependencies, images, and IaC | Trivy, Checkov, tfsec               | Scan results              | Scan logs                  |

| 9       | Secrets Management     | Protect credentials        | Configure GitHub and AWS secrets   | GitHub Secrets, AWS Secrets Manager | Secrets hidden            | Secrets screenshots        |

| 10      | Evidence Collection    | Prove delivery             | Capture outputs and screenshots    | CLI, browser, GitHub, AWS           | Review evidence           | Evidence folder            |

| 11      | README Documentation   | Support onboarding         | Write documentation                | Markdown files                      | Complete READMEs          | GitHub file screenshots    |

| 12      | Final Verification     | Confirm completion         | Review checklist                   | Completion table                    | Demo-ready project        | Verification table         |



\---



\## 6. Terraform



Terraform is used to provision AWS infrastructure as code. This ensures the cloud environment is repeatable, reviewable, and not dependent on manual AWS Console changes.



Terraform should manage the following infrastructure where applicable:



\* Networking

\* Security groups

\* EC2 instance

\* IAM role or IAM policy

\* Secrets Manager access

\* k3s host configuration

\* Useful outputs such as public IP and instance ID



A recommended Terraform structure is:



```text

terraform/

├── main.tf

├── variables.tf

├── outputs.tf

├── providers.tf

├── terraform.tfvars.example

└── modules/

&#x20;   ├── networking/

&#x20;   └── compute/

```



For a capstone project, local Terraform state may be acceptable if it is protected and not committed. For production, use an S3 backend with DynamoDB state locking.



Run these Terraform commands from the Terraform directory:



```bash

terraform fmt

terraform init

terraform validate

terraform plan

terraform apply

terraform output

```



| Terraform Command    | Purpose                    | Expected Output              | Evidence Needed     |

| -------------------- | -------------------------- | ---------------------------- | ------------------- |

| `terraform fmt`      | Format Terraform files     | Files are formatted          | Terminal screenshot |

| `terraform init`     | Initialize Terraform       | Providers are installed      | Init screenshot     |

| `terraform validate` | Validate syntax            | Configuration is valid       | Validate screenshot |

| `terraform plan`     | Preview changes            | Resource plan is shown       | Plan screenshot     |

| `terraform apply`    | Create AWS resources       | Apply completes successfully | Apply screenshot    |

| `terraform output`   | Show infrastructure values | Public IP and IDs are shown  | Output screenshot   |



\---



\## 7. Kubernetes / K3s



k3s is the lightweight Kubernetes runtime used to run the Zuri Market application on AWS EC2.



The Kubernetes layer should include:



\* Namespace

\* Frontend Deployment

\* Backend Deployment

\* Service

\* Ingress, if used

\* ConfigMap

\* Secret

\* Health checks

\* Rollout verification



The runtime flow is:



```text

DockerHub Image

→ Kubernetes Deployment

→ Pods

→ Service or Ingress

→ Users

```



Useful Kubernetes commands:



```bash

kubectl get nodes

kubectl get pods -A

kubectl get deployments

kubectl get svc

kubectl get ingress

kubectl describe pod <pod-name>

kubectl logs <pod-name>

kubectl rollout status deployment/<deployment-name>

```



| Kubernetes Area | Command                                               | Expected Result           | Evidence Needed  |

| --------------- | ----------------------------------------------------- | ------------------------- | ---------------- |

| Node health     | `kubectl get nodes`                                   | Node is `Ready`           | CLI screenshot   |

| All pods        | `kubectl get pods -A`                                 | Pods are running          | CLI screenshot   |

| Deployments     | `kubectl get deployments`                             | Deployments are available | CLI screenshot   |

| Services        | `kubectl get svc`                                     | Services are exposed      | CLI screenshot   |

| Ingress         | `kubectl get ingress`                                 | Ingress has address       | CLI screenshot   |

| Pod details     | `kubectl describe pod <pod-name>`                     | Events are visible        | Debug screenshot |

| Pod logs        | `kubectl logs <pod-name>`                             | Logs are visible          | Log screenshot   |

| Rollout         | `kubectl rollout status deployment/<deployment-name>` | Rollout is complete       | CLI screenshot   |



\---



\## 8. CI/CD Workflow



The CI/CD workflow is powered by GitHub Actions. It starts when code is pushed to the `main` branch.



The pipeline should:



1\. Check out the repository.

2\. Install dependencies.

3\. Run frontend tests.

4\. Run backend tests.

5\. Scan dependencies.

6\. Scan Terraform code.

7\. Build Docker images.

8\. Scan Docker images.

9\. Push images to DockerHub.

10\. Deploy to k3s.

11\. Verify rollout.



| Pipeline Stage  | Tool             | Trigger          | Input                | Action               | Output                 | Evidence             |

| --------------- | ---------------- | ---------------- | -------------------- | -------------------- | ---------------------- | -------------------- |

| Checkout        | GitHub Actions   | Push to `main`   | Repository code      | Pull source code     | Code ready             | Workflow logs        |

| Install         | npm              | Workflow run     | `package.json`       | Install dependencies | Dependencies installed | Workflow logs        |

| Frontend Test   | npm              | After install    | Frontend code        | Run tests            | Test result            | Workflow logs        |

| Backend Test    | npm              | After install    | Backend code         | Run tests            | Test result            | Workflow logs        |

| Dependency Scan | npm audit        | Before build     | Node dependencies    | Scan packages        | Audit report           | Workflow logs        |

| IaC Scan        | Checkov or tfsec | Before deploy    | Terraform files      | Scan IaC             | Scan report            | Workflow logs        |

| Docker Build    | Docker           | After scans      | Dockerfiles          | Build images         | Images built           | Workflow logs        |

| Image Scan      | Trivy            | Before push      | Docker images        | Scan images          | Image scan report      | Trivy logs           |

| Docker Push     | DockerHub        | After build      | Built images         | Push tags            | Images in DockerHub    | DockerHub screenshot |

| Terraform Check | Terraform        | Before deploy    | IaC files            | Validate plan        | Valid IaC              | Workflow logs        |

| k3s Deploy      | kubectl          | After image push | Kubernetes manifests | Apply YAML           | Updated application    | Workflow logs        |

| Rollout Check   | kubectl          | After deploy     | Deployment name      | Verify rollout       | Success or failure     | Workflow logs        |



If a test, scan, build, push, Terraform step, or rollout check fails, the pipeline should stop. This prevents broken or insecure changes from reaching the runtime environment.



\---



\## 9. Secrets Management



Secrets must never be committed to GitHub, stored in Docker images, pasted into Slack, or written directly into Kubernetes manifests.



The project uses four secret layers:



1\. Local development: `.env`

2\. Safe templates: `.env.example`

3\. CI/CD: GitHub Actions Secrets

4\. Runtime: AWS Secrets Manager and Kubernetes Secrets



| Secret                  | Stored In                        | Used By     | Purpose                 | Security Decision             |

| ----------------------- | -------------------------------- | ----------- | ----------------------- | ----------------------------- |

| `DOCKERHUB\_USERNAME`    | GitHub Actions Secrets           | CI/CD       | DockerHub login         | Do not store in workflow YAML |

| `DOCKERHUB\_TOKEN`       | GitHub Actions Secrets           | CI/CD       | Push Docker images      | Use token instead of password |

| `AWS\_ACCESS\_KEY\_ID`     | GitHub Actions Secrets           | CI/CD       | AWS authentication      | Store as encrypted secret     |

| `AWS\_SECRET\_ACCESS\_KEY` | GitHub Actions Secrets           | CI/CD       | AWS authentication      | Store as encrypted secret     |

| `KUBECONFIG`            | GitHub Actions Secrets           | CI/CD       | k3s access              | Do not commit kubeconfig      |

| `SSH\_PRIVATE\_KEY`       | GitHub Actions Secrets           | CI/CD       | EC2 access if needed    | Restrict usage                |

| `API\_SECRET\_KEY`        | AWS Secrets Manager              | Backend     | Backend app secret      | Runtime only                  |

| `STORE\_NAME`            | AWS Secrets Manager or ConfigMap | Application | Store configuration     | Do not hardcode               |

| Database URL            | AWS Secrets Manager              | Backend     | Database connection     | Runtime only                  |

| Third-party API keys    | AWS Secrets Manager              | Application | External service access | Central storage               |



Recommended `.gitignore` block:



```gitignore

\# Environment files

.env

.env.\*

!.env.example



\# Terraform local files and state

terraform.tfvars

\*.tfvars

\*.tfstate

\*.tfstate.\*

.terraform/

.terraform.lock.hcl



\# Node dependencies and builds

node\_modules/

dist/

build/



\# Logs

\*.log

npm-debug.log\*



\# OS/editor files

.DS\_Store

.vscode/

.idea/



\# Kubernetes and private keys

\*kubeconfig\*

\*.pem

\*.key

```



Pipeline secrets should be configured in GitHub:



```text

Settings → Secrets and variables → Actions

```



Runtime secrets should be stored in AWS Secrets Manager and injected into Kubernetes using a secure pattern such as:



\* AWS Secrets Manager CSI Driver

\* External Secrets Operator

\* Controlled CI/CD secret sync

\* Application retrieval through AWS SDK



Kubernetes Secrets are base64-encoded by default. They should not be committed to Git with real values.



\---



\## 10. Security Decisions



| Security Area           | Decision                          | Reason                        | Evidence                   |

| ----------------------- | --------------------------------- | ----------------------------- | -------------------------- |

| IAM                     | Use least privilege               | Limit blast radius            | IAM screenshot             |

| Secrets                 | Use managed secret stores         | Avoid code leaks              | GitHub and AWS screenshots |

| Local environment files | Ignore `.env` files               | Prevent accidental commits    | `git status` output        |

| Dependency scanning     | Run `npm audit`                   | Find vulnerable packages      | Pipeline logs              |

| Image scanning          | Run Trivy                         | Find vulnerable image layers  | Trivy logs                 |

| IaC scanning            | Run Checkov or tfsec              | Catch cloud misconfigurations | Scan logs                  |

| Kubernetes secrets      | Do not commit real values         | Avoid secret leakage          | Repo search screenshot     |

| Network access          | Open required ports only          | Reduce attack surface         | Security group evidence    |

| CI/CD trigger           | Deploy from `main` only           | Control release flow          | Workflow file              |

| Terraform validation    | Run `fmt`, `validate`, and `plan` | Safer infrastructure changes  | Terraform logs             |

| Health checks           | Verify app status                 | Confirm runtime health        | `curl` output              |

| Logging                 | Capture pod logs                  | Support troubleshooting       | `kubectl logs` output      |

| Evidence collection     | Store screenshots                 | Prove delivery                | Evidence folder            |



\---



\## 11. Evidence Checklist



| Evidence Item            | Command or Screenshot Needed | Expected Result       | Where to Store Evidence                |

| ------------------------ | ---------------------------- | --------------------- | -------------------------------------- |

| Terraform init           | `terraform init`             | Init successful       | `docs/evidence/terraform-init.png`     |

| Terraform validate       | `terraform validate`         | Config valid          | `docs/evidence/terraform-validate.png` |

| Terraform plan           | `terraform plan`             | Plan shown            | `docs/evidence/terraform-plan.png`     |

| Terraform apply          | `terraform apply`            | Apply complete        | `docs/evidence/terraform-apply.png`    |

| Terraform output         | `terraform output`           | Outputs shown         | `docs/evidence/terraform-output.png`   |

| AWS resources            | AWS Console screenshot       | Resources exist       | `docs/evidence/aws-resources.png`      |

| K3s node ready           | `kubectl get nodes`          | Node is ready         | `docs/evidence/k3s-node-ready.png`     |

| Kubernetes pods          | `kubectl get pods -A`        | Pods are running      | `docs/evidence/k8s-pods.png`           |

| Kubernetes deployments   | `kubectl get deployments`    | Deployments are ready | `docs/evidence/k8s-deployments.png`    |

| Kubernetes services      | `kubectl get svc`            | Services are exposed  | `docs/evidence/k8s-services.png`       |

| Kubernetes ingress       | `kubectl get ingress`        | Ingress is working    | `docs/evidence/k8s-ingress.png`        |

| GitHub Actions run       | Actions screenshot           | Workflow passed       | `docs/evidence/actions-success.png`    |

| DockerHub images         | DockerHub screenshot         | Images are pushed     | `docs/evidence/dockerhub.png`          |

| Frontend live URL        | Browser screenshot           | App loads             | `docs/evidence/frontend-live.png`      |

| Backend health endpoint  | `curl <url>/health`          | Healthy response      | `docs/evidence/backend-health.png`     |

| Secret repository search | GitHub search screenshot     | No secrets found      | `docs/evidence/no-secrets.png`         |

| GitHub Actions Secrets   | Settings screenshot          | Secrets configured    | `docs/evidence/github-secrets.png`     |

| AWS Secrets Manager      | AWS screenshot               | Secrets stored        | `docs/evidence/aws-secrets.png`        |

| Root README              | GitHub file view             | README complete       | `docs/evidence/root-readme.png`        |

| Frontend README          | GitHub file view             | README complete       | `docs/evidence/frontend-readme.png`    |

| Backend README           | GitHub file view             | README complete       | `docs/evidence/backend-readme.png`     |



\---



\## 12. Capstone Deliverable Completion Verification



| Deliverable Requirement                     | Completed? | Evidence               | Notes                    |

| ------------------------------------------- | ---------- | ---------------------- | ------------------------ |

| Frontend app runs and fetches backend API   | Pending    | Live URL               | Confirm after deployment |

| Backend API returns correct data            | Pending    | Postman or `curl`      | Confirm endpoints        |

| Frontend Dockerfile builds successfully     | Pending    | Build logs             | Confirm Dockerfile       |

| Backend Dockerfile builds successfully      | Pending    | Build logs             | Confirm Dockerfile       |

| Images are pushed to DockerHub              | Pending    | DockerHub screenshot   | Confirm tags             |

| Workflow triggers on push to `main`         | Pending    | GitHub Actions tab     | Confirm trigger          |

| Dependency scanning runs                    | Pending    | GitHub Actions logs    | Confirm scan step        |

| Docker image scanning runs                  | Pending    | Trivy logs             | Confirm scan step        |

| Critical findings block deployment          | Pending    | Failed gate evidence   | Confirm policy           |

| Pipeline builds and pushes images           | Pending    | GitHub Actions logs    | Confirm image push       |

| Pipeline deploys to k3s                     | Pending    | GitHub Actions logs    | Confirm rollout          |

| Terraform provisions EC2 and IAM            | Pending    | Terraform output       | Confirm resources        |

| No manual AWS Console creation              | Pending    | Mentor verification    | Explain during demo      |

| App is deployed with Deployment and Service | Pending    | `kubectl` output       | Confirm resources        |

| App is accessible by public IP or domain    | Pending    | Browser screenshot     | Confirm access           |

| No secrets are in the GitHub repository     | Pending    | Repo search screenshot | Confirm `.env` ignored   |

| Secrets are stored in AWS Secrets Manager   | Pending    | AWS screenshot         | Confirm secret location  |

| GitHub Actions Secrets are configured       | Pending    | Settings screenshot    | Confirm secret names     |

| Backend README is complete                  | Completed  | `backend/README.md`    | Finalize Stage 5         |

| Frontend README is complete                 | Completed  | `frontend/README.md`   | Finalize Stage 4         |

| Root Infrastructure README is complete      | Completed  | `README.md`            | This document            |



Only these statuses should be used in the `Completed?` column:



\* Completed

\* Partially Completed

\* Pending



\---



\## 13. Runbook



\### Deploy Application



```bash

kubectl apply -f k8s/

kubectl rollout status deployment/<deployment-name>

kubectl get pods

kubectl get svc

```



\### Rollback Application



```bash

kubectl rollout history deployment/<deployment-name>

kubectl rollout undo deployment/<deployment-name>

kubectl rollout status deployment/<deployment-name>

```



\### Check App Health



```bash

curl http://<public-ip-or-domain>/health

```



\### Troubleshoot Failed Pods



```bash

kubectl get pods

kubectl describe pod <pod-name>

kubectl logs <pod-name>

kubectl get events --sort-by=.lastTimestamp

```



\### Troubleshoot Failed CI/CD Runs



```bash

git status

git log --oneline -5

```



Then check the failed workflow in GitHub:



```text

GitHub Repository → Actions → Failed Workflow → Failed Job → Failed Step

```



\### Check Logs



```bash

kubectl logs <pod-name>

kubectl logs deployment/<deployment-name>

```



\### Verify Terraform State



```bash

terraform state list

terraform output

terraform plan

```



\### Rotate Secrets



```bash

kubectl rollout restart deployment/<deployment-name>

kubectl rollout status deployment/<deployment-name>

```



Secret rotation process:



1\. Update the value in AWS Secrets Manager.

2\. Redeploy or restart the workload.

3\. Confirm the application still works.

4\. Remove or disable old credentials where appropriate.



\### Destroy Infrastructure Safely



```bash

terraform plan -destroy

terraform destroy

```



Only destroy infrastructure after the demo, evidence capture, and final review are complete.



| Scenario               | Command or Action                          | Expected Result           | Next Step if Failed |

| ---------------------- | ------------------------------------------ | ------------------------- | ------------------- |

| Deploy app             | `kubectl apply -f k8s/`                    | Resources applied         | Check YAML          |

| Verify rollout         | `kubectl rollout status deployment/<name>` | Rollout complete          | Check pod logs      |

| Rollback app           | `kubectl rollout undo deployment/<name>`   | Previous version restored | Set image manually  |

| Check pods             | `kubectl get pods`                         | Pods running              | Describe pod        |

| Check service          | `kubectl get svc`                          | Service exists            | Check selector      |

| Check ingress          | `kubectl get ingress`                      | Address shown             | Check controller    |

| Check logs             | `kubectl logs <pod>`                       | Logs visible              | Check pod name      |

| Check health           | `curl <url>/health`                        | Healthy response          | Check service       |

| Validate Terraform     | `terraform validate`                       | Config valid              | Fix syntax          |

| Check drift            | `terraform plan`                           | No drift                  | Investigate changes |

| Rotate secret          | Update AWS secret                          | New value used            | Check IAM           |

| Destroy infrastructure | `terraform destroy`                        | Resources removed         | Resolve dependency  |



\---



\## 14. Production Readiness



| Area             | Current State               | Production Gap                | Recommendation                      |

| ---------------- | --------------------------- | ----------------------------- | ----------------------------------- |

| Availability     | k3s runs on EC2             | Single-node risk              | Use EKS or multi-node k3s           |

| Security         | Scans and secrets added     | More hardening needed         | Add policy-as-code                  |

| Monitoring       | Basic logs available        | No full observability stack   | Add Prometheus, Grafana, and Loki   |

| Backup           | Terraform can rebuild infra | No data backup plan           | Add backup strategy                 |

| Secrets          | AWS Secrets Manager used    | Rotation may be manual        | Automate rotation                   |

| CI/CD Governance | GitHub Actions used         | Approval gates may be missing | Add GitHub Environments             |

| Terraform State  | Terraform state used        | Local state risk              | Use S3 backend and DynamoDB locking |

| Scaling          | Kubernetes workloads used   | EC2 node limit                | Add HPA or move to EKS              |

| Cost Control     | EC2-based setup             | No budget alerts              | Add AWS Budgets                     |

| Documentation    | READMEs planned             | Evidence still needed         | Add screenshots                     |



\---



\## 15. Future Improvements



| Improvement            | Benefit                       | Priority | Suggested Tool or Approach       |

| ---------------------- | ----------------------------- | -------- | -------------------------------- |

| Move to EKS            | Better availability           | High     | Amazon EKS                       |

| Remote Terraform state | Safer collaboration           | High     | S3 and DynamoDB                  |

| Branch protection      | Safer releases                | High     | GitHub branch rules              |

| Approval gates         | Controlled production release | Medium   | GitHub Environments              |

| Observability          | Faster troubleshooting        | High     | Prometheus, Grafana, Loki        |

| Secret rotation        | Lower credential risk         | Medium   | AWS Secrets Manager rotation     |

| External secrets       | Safer secret sync             | High     | External Secrets Operator        |

| TLS certificates       | Secure public traffic         | High     | cert-manager                     |

| Domain name            | Stable access                 | Medium   | Route 53                         |

| Autoscaling            | Handle traffic spikes         | Medium   | Kubernetes HPA                   |

| Policy-as-code         | Enforce controls              | Medium   | OPA or Kyverno                   |

| Image signing          | Improve supply chain trust    | Low      | Cosign                           |

| SBOM generation        | Improve dependency visibility | Medium   | Syft                             |

| DR runbook             | Improve recovery readiness    | Medium   | Backup and restore documentation |



\---



\## 16. Final Verification Summary



This root Infrastructure README documents the full Zuri Market DevSecOps workflow from developer commit to production runtime on AWS-hosted k3s.



Created or documented items include:



\* Executive summary

\* Pain points and solutions

\* Repository map

\* Architecture image reference

\* Project stages

\* Terraform guide

\* Kubernetes/k3s guide

\* CI/CD workflow

\* Secrets management model

\* Security decisions

\* Evidence checklist

\* Capstone verification table

\* Runbook

\* Production readiness review

\* Future improvements



The evaluator should verify:



\* Push to `main` triggers GitHub Actions.

\* Pipeline runs tests and security scans.

\* Docker images are pushed to DockerHub.

\* Terraform provisions AWS infrastructure.

\* Application runs inside k3s.

\* App is accessible by public IP or domain.

\* No secrets are committed to GitHub.

\* Runtime secrets are stored in AWS Secrets Manager.

\* GitHub Actions Secrets are configured.

\* Frontend and backend README files are complete.



Evidence still needed:



\* Terraform command screenshots

\* AWS resource screenshots

\* DockerHub image screenshot

\* GitHub Actions successful run

\* k3s node readiness

\* Kubernetes pods, services, deployments, and ingress

\* Live frontend screenshot

\* Backend health endpoint screenshot

\* Secret search screenshot

\* GitHub Actions Secrets screenshot

\* AWS Secrets Manager screenshot



Expected files in the repository:



```text

zuri-market-infra/

├── README.md

├── frontend/

│   └── README.md

├── backend/

│   └── README.md

├── terraform/

├── k8s/

├── docs/

│   └── images/

│       └── zuri-market-devsecops-architecture.png

└── .github/

&#x20;   └── workflows/

```



