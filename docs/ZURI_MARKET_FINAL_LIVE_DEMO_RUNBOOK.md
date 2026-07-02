# Zuri Market DevSecOps Reviewer Demo Runbook

## Purpose

This runbook is the final, clean demonstration path for the Zuri Market DevSecOps capstone. It incorporates the lessons from the earlier start-and-stop demo attempts:

- Terraform resources must use a unique environment per workflow run to avoid duplicate AWS key pair and IAM role names.
- GitHub Actions must wait for EC2 to appear in AWS Systems Manager before sending SSM commands.
- SSM deployment must wait for `cloud-init` and `k3s` readiness before applying Kubernetes manifests.
- The Kubernetes folder is `kubernetes/`, not `k8s/`.
- Reviewer evidence must show scale-up, deletion, outage, self-healing, endpoint recovery, and auto-destroy.

The final demo is triggered by a pull request merge into `main`, not by a manual workflow run.

---

## Demo outcome

At the end of a successful run, the reviewer can see that:

1. A PR merge triggers the workflow automatically.
2. Backend and frontend code are tested.
3. Code, filesystem, Terraform, and Kubernetes files are scanned.
4. Docker images are built and pushed to DockerHub.
5. Terraform provisions temporary AWS infrastructure.
6. AWS Systems Manager proves remote runtime control without manual SSH.
7. k3s is installed and verified on EC2.
8. Kubernetes workloads are deployed using `kubectl apply -k kubernetes/`.
9. Initial deployments start with one frontend pod and one backend pod.
10. A timed Kubernetes Job scales each deployment after three minutes.
11. The workflow deletes both deployments and proves the app endpoint fails.
12. A Kubernetes CronJob self-heals the deleted deployments within the reconciliation window.
13. The endpoint recovers after self-healing.
14. The workflow preannounces auto-destroy.
15. Terraform destroys the temporary AWS infrastructure automatically.

---

## Required repository settings

### GitHub Secrets

Create these under **Settings → Secrets and variables → Actions → Secrets**:

| Secret | Required | Purpose |
|---|---:|---|
| `AWS_ACCESS_KEY_ID` | Yes | Allows GitHub Actions to call AWS. |
| `AWS_SECRET_ACCESS_KEY` | Yes | Secret key for the AWS IAM user. |
| `DOCKERHUB_USERNAME` | Yes | DockerHub username. |
| `DOCKERHUB_TOKEN` | Yes | DockerHub token for image push. |
| `DEMO_SSH_PUBLIC_KEY` | Optional | Enables optional SSH from your laptop using your matching private key. |

### GitHub Variables

Create this under **Settings → Secrets and variables → Actions → Variables**:

| Variable | Required | Example | Purpose |
|---|---:|---|---|
| `ALLOWED_SSH_CIDR` | Yes | `142.198.247.98/32` | Restricts SSH/k3s API access to your public IP. |

To get your current public IP from PowerShell:

```powershell
$ip = (Invoke-RestMethod https://checkip.amazonaws.com).Trim()
"$ip/32"
```

---

## AWS IAM permissions needed by the GitHub Actions user

For a fast capstone demo, the AWS IAM user behind `AWS_ACCESS_KEY_ID` needs permissions for:

- EC2 VPC, subnet, route table, security group, EIP, key pair, and instance creation/deletion.
- IAM role and instance profile creation/deletion.
- IAM PassRole for the EC2 instance profile.
- SSM Run Command and command result reads.
- Secrets Manager read access if the backend checks runtime secrets.

For a controlled student demo, attach temporary broad policies if your instructor allows it:

- `AmazonEC2FullAccess`
- `AmazonSSMFullAccess`
- `IAMFullAccess`
- `SecretsManagerReadWrite`

Then remove or narrow them after the demo.

---

## Repository files used in the final demo

| Path | Purpose |
|---|---|
| `.github/workflows/ephemeral-demo.yml` | PR-merge triggered reviewer demo workflow. |
| `terraform/` | Provisions temporary AWS infrastructure. |
| `kubernetes/kustomization.yaml` | Bundles all Kubernetes manifests. |
| `kubernetes/automation-rbac.yaml` | Allows the timed Job and reconciler CronJob to patch/create deployments. |
| `kubernetes/timed-scale-job.yaml` | Waits three minutes, patches labels, and scales frontend/backend to two replicas. |
| `kubernetes/deployment-reconciler-cronjob.yaml` | Runs every three minutes and recreates missing deployments. |
| `kubernetes/backend-deployment.yaml` | Backend starts with one replica and is labelled for reviewer proof. |
| `kubernetes/frontend-deployment.yaml` | Frontend starts with one replica and is labelled for reviewer proof. |
| `kubernetes/backend-service.yaml` | Internal backend service. |
| `kubernetes/frontend-service.yaml` | NodePort service exposing the app on port `30080`. |

---

## Pre-demo checklist

Run these locally before opening/merging the final PR:

```powershell
git status
kubectl kustomize .\kubernetes\ > $null
cd terraform
terraform fmt
terraform validate
cd ..
```

Expected results:

- `kubectl kustomize` returns silently.
- Terraform says `Success! The configuration is valid.`
- Git only shows intentional files changed.

---

## How to trigger the final demo

The workflow is no longer triggered manually. It runs when a pull request is merged into `main`.

Recommended flow:

```powershell
git checkout -b final-reviewer-demo-update
git add .github\workflows\ephemeral-demo.yml kubernetes README.md docs
git commit -m "Finalize PR merge reviewer demo automation"
git push origin final-reviewer-demo-update
```

Then in GitHub:

1. Open a pull request from `final-reviewer-demo-update` into `main`.
2. Confirm the changed files.
3. Merge the PR.
4. Go to **Actions**.
5. Open **Zuri Market Ephemeral DevSecOps Demo**.
6. Watch the automatically triggered run.

---

## What to narrate during the demo

### Stage 1 — PR merge trigger

Say:

> The deployment is triggered by a pull request merge into main. This simulates a controlled production release gate rather than someone manually clicking a deployment button.

Evidence:

- GitHub Actions event shows PR merge.
- Branch shows `main`.

### Stage 2 — CI and security validation

Say:

> The workflow checks out the infrastructure repo and the separate frontend/backend repos. It installs dependencies, runs test/build checks, and scans with Trivy and Checkov before deployment.

Evidence:

- Backend install and smoke test.
- Frontend install and build.
- Trivy scans.
- Checkov Terraform scan.
- Kubernetes kustomize render check.

### Stage 3 — Image build and push

Say:

> The workflow builds immutable Docker images and pushes them to DockerHub with the merge commit tag and `latest`.

Evidence:

- Build and push backend image.
- Build and push frontend image.
- Image tag shown in logs.

### Stage 4 — Terraform infrastructure provisioning

Say:

> Terraform creates a temporary AWS runtime environment. The environment name is unique per workflow run, so repeated demos do not collide with old key pairs or IAM roles.

Evidence:

- Terraform plan/apply output.
- Outputs: `instance_id`, `public_ip`, `app_url`.

### Stage 5 — SSM runtime control

Say:

> I do not need to SSH manually. GitHub Actions waits for the EC2 instance to appear in AWS Systems Manager, then uses SSM Run Command to control the k3s node.

Evidence:

- SSM managed node wait.
- SSM command ID.
- `sudo cloud-init status --wait`.
- `sudo systemctl is-active k3s`.
- `sudo k3s kubectl get nodes -o wide`.

### Stage 6 — Kubernetes deployment

Say:

> Workloads are deployed using Kustomize from the `kubernetes/` folder. This includes the app workloads and the reviewer automation resources.

Evidence:

- `sudo k3s kubectl apply -k kubernetes/`.
- `kubectl get all -n zuri-market`.
- `kubectl get pods --show-labels`.

### Stage 7 — Initial one-replica proof

Say:

> The backend and frontend intentionally start with one replica each so the timed scale-up is visible.

Evidence:

- `zuri-backend` ready replicas = 1.
- `zuri-frontend` ready replicas = 1.

### Stage 8 — Timed three-minute scale-up

Say:

> A Kubernetes Job waits three minutes and scales both deployments to two replicas. It also labels the new pods so the reviewer can identify them.

Evidence:

- Job: `zuri-scale-after-3-mins`.
- Backend ready replicas >= 2.
- Frontend ready replicas >= 2.
- Pods with label `demo.zuri-market/scaled-after-3-mins=true`.

### Stage 9 — Delete, outage, and self-heal proof

Say:

> The workflow deletes both deployments, shows they are deleted, proves the application endpoint fails, then waits for the reconciler CronJob to recreate the deployments.

Evidence:

- `kubectl get deployments -n zuri-market -o wide` before deletion.
- `kubectl delete deployment zuri-backend zuri-frontend`.
- `CONFIRMED: zuri-backend deployment deleted`.
- `CONFIRMED: zuri-frontend deployment deleted`.
- `EXPECTED FAILURE: endpoint unavailable after deployment deletion`.
- `zuri-deployment-reconciler` CronJob.
- Recreated pods with `demo.zuri-market/recreated-by-reconciler=true`.
- Endpoint curl succeeds after recovery.

### Stage 10 — Auto-destroy

Say:

> The workflow preannounces the destroy time and automatically destroys the AWS infrastructure after the runtime demo window.

Evidence:

- Auto-destroy warning log.
- Final destroy warning.
- `terraform destroy` complete.

---

## Optional SSH into the EC2/k3s server

The main demo does not require SSH. SSH is optional only for instructor questions or live exploration.

### Enable optional SSH

On your laptop, create a key pair:

```powershell
ssh-keygen -t ed25519 -f $HOME\.ssh\zuri_demo_key -N "" -C "temi-zuri-demo"
Get-Content $HOME\.ssh\zuri_demo_key.pub
```

Copy the public key text and save it in GitHub as:

```text
Settings → Secrets and variables → Actions → Secrets → DEMO_SSH_PUBLIC_KEY
```

Set `ALLOWED_SSH_CIDR` to your current public IP with `/32`.

### Get the EC2 public IP during the run

Open the successful running workflow and expand:

```text
Terraform apply temporary runtime infrastructure
```

Look for:

```text
Public IP: x.x.x.x
Application URL: http://x.x.x.x:30080
```

### SSH command

Run from PowerShell during the 15-minute runtime window:

```powershell
ssh -i $HOME\.ssh\zuri_demo_key ubuntu@<PUBLIC_IP>
```

### Useful k3s commands after SSH

```bash
sudo systemctl status k3s --no-pager
sudo k3s kubectl get nodes -o wide
sudo k3s kubectl get all -n zuri-market
sudo k3s kubectl get deployments -n zuri-market --show-labels
sudo k3s kubectl get pods -n zuri-market --show-labels
sudo k3s kubectl get svc -n zuri-market
sudo k3s kubectl get cronjob -n zuri-market
sudo k3s kubectl get jobs -n zuri-market
```

### Manually delete deployments and observe endpoint failure

Before deletion:

```bash
curl -i http://localhost:30080/api/products
sudo k3s kubectl get deployments -n zuri-market
```

Delete deployments:

```bash
sudo k3s kubectl delete deployment zuri-backend zuri-frontend -n zuri-market --wait=true
sudo k3s kubectl get deployments -n zuri-market || true
```

Test endpoint while deployments are gone:

```bash
curl -i --connect-timeout 5 http://localhost:30080/api/products
```

Expected effect:

- The deployments are missing.
- Pods disappear.
- The service still exists, but it has no healthy backend/frontend pods.
- The app endpoint fails temporarily.

Wait for self-healing:

```bash
sleep 240
sudo k3s kubectl get deployments -n zuri-market --show-labels
sudo k3s kubectl get pods -n zuri-market --show-labels
curl -i http://localhost:30080/api/products
```

Expected effect:

- The reconciler CronJob recreates missing deployments.
- Pods return.
- The endpoint succeeds again.

---

## Evidence collection checklist

Capture screenshots of these successful workflow sections:

| Evidence | Screenshot target |
|---|---|
| PR merge trigger | Actions run header showing PR merge event and `main`. |
| CI passed | Backend/frontend test and build steps. |
| Security scan | Trivy and Checkov steps. |
| Image push | DockerHub build and push steps. |
| Terraform apply | Resources created and outputs shown. |
| SSM node online | Wait for EC2 in Systems Manager. |
| k3s readiness | cloud-init wait and `systemctl is-active k3s`. |
| Kubernetes deployment | `kubectl apply -k kubernetes/`. |
| Initial replicas | One backend and one frontend replica. |
| Timed scale-up | Ready replicas >= 2 and scaled label shown. |
| Delete and outage | Deleted deployments and failed curl. |
| Self-healing | Recreated deployments/pods and recovered curl. |
| Auto-destroy | Preannouncement, final warning, and Terraform destroy complete. |

---

## Known failure fixes already built into this runbook

| Earlier issue | Final fix |
|---|---|
| Manual workflow trigger created inconsistent starts. | Workflow now runs on PR merge into `main`. |
| Duplicate AWS key pair/IAM role. | `TF_ENVIRONMENT=demo-${{ github.run_id }}` creates unique names per run. |
| Blank CIDR broke security group creation. | `ALLOWED_SSH_CIDR` is required and documented. |
| SSM came online before k3s was active. | SSM deploy waits for cloud-init and k3s readiness. |
| Wrong path `k8s/`. | Workflow uses `kubernetes/`. |
| Hard-to-read self-healing proof. | Workflow now shows before delete, delete, deleted, failed curl, recovery, and successful curl. |

---

## Final reviewer closing statement

Use this closing summary:

> This demo proves a secure, automated, repeatable DevSecOps deployment path for Zuri Market. A pull request merge triggers CI, security scans, Docker image build/push, Terraform provisioning, SSM-based runtime deployment into k3s, Kubernetes self-healing validation, endpoint verification, evidence collection, and automatic infrastructure destruction. Secrets are kept out of source code, runtime access is controlled through AWS Systems Manager, and every major control is visible in the workflow logs.
