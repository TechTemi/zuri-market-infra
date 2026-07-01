\# Zuri Market Frontend



\## 1. Frontend Overview



The Zuri Market frontend is the customer-facing web application for the Zuri Market e-commerce platform.



It displays African artisan products, connects to the backend API, shows store information, and provides a clean browsing experience for customers.



The frontend is designed to run locally during development, build into static production assets, and deploy through the DevSecOps CI/CD workflow as a Docker container.



\---



\## 2. Tech Stack



| Technology     | Purpose                               |

| -------------- | ------------------------------------- |

| React          | Builds the user interface             |

| Vite           | Runs dev server and production builds |

| JavaScript     | Main frontend language                |

| npm            | Manages packages and scripts          |

| Docker         | Packages the frontend                 |

| Nginx          | Serves production assets              |

| GitHub Actions | Automates CI/CD                       |

| DockerHub      | Stores frontend images                |

| Kubernetes/k3s | Runs the deployed container           |



\---



\## 3. Folder Structure



Recommended frontend structure:



```text

frontend/

├── README.md

├── package.json

├── package-lock.json

├── Dockerfile

├── nginx.conf

├── .env.example

├── .gitignore

├── index.html

├── vite.config.js

├── public/

└── src/

\&#x20;   ├── App.jsx

\&#x20;   ├── main.jsx

\&#x20;   ├── components/

\&#x20;   ├── pages/

\&#x20;   ├── services/

\&#x20;   └── styles/

```



| Path              | Purpose                          |

| ----------------- | -------------------------------- |

| `package.json`    | Defines dependencies and scripts |

| `Dockerfile`      | Builds the frontend image        |

| `nginx.conf`      | Serves production build          |

| `.env.example`    | Shows safe variable examples     |

| `index.html`      | Vite HTML entry point            |

| `vite.config.js`  | Vite configuration               |

| `src/main.jsx`    | React entry file                 |

| `src/App.jsx`     | Main app component               |

| `src/components/` | Reusable UI components           |

| `src/pages/`      | Page-level views                 |

| `src/services/`   | API client logic                 |

| `src/styles/`     | Styling files                    |



\### Component Reference



| Component or Area  | Purpose               | Data Used             |

| ------------------ | --------------------- | --------------------- |

| `App.jsx`          | Main app shell        | Store name and routes |

| Product components | Display products      | Product API data      |

| Cart components    | Show selected items   | Cart state            |

| API service        | Calls backend API     | `VITE\\\_API\\\_URL`        |

| Layout components  | Render page structure | Static UI data        |



Update this section when the final component names are confirmed.



\---



\## 4. Environment Variables



The frontend uses Vite environment variables.



Vite only exposes variables to the browser when they start with `VITE\\\_`.



| Variable          | Required | Example Value           | Purpose              |

| ----------------- | -------- | ----------------------- | -------------------- |

| `VITE\\\_API\\\_URL`    | Yes      | `http://localhost:3000` | Backend API base URL |

| `VITE\\\_STORE\\\_NAME` | Yes      | `Zuri Market`           | Store display name   |



Create a local environment file:



```bash

cp .env.example .env

```



Example `.env.example`:



```env

VITE\\\_API\\\_URL=http://localhost:3000

VITE\\\_STORE\\\_NAME=Zuri Market

```



Do not commit the real `.env` file.



Frontend environment variables are visible in the browser. Do not place passwords, private keys, access tokens, database URLs, or backend-only secrets in any `VITE\\\_` variable.



\---



\## 5. Local Setup



\### Prerequisites



| Tool    | Required Version |

| ------- | ---------------- |

| Node.js | 18 or later      |

| npm     | 9 or later       |

| Git     | Latest stable    |

| Docker  | Latest stable    |



\### Clone the Repository



```bash

git clone https://github.com/TechTemi/zuri-market-infra.git

cd zuri-market-infra/frontend

```



\### Install Dependencies



```bash

npm install

```



\### Create Local Environment File



```bash

cp .env.example .env

```



Update `.env` with the correct backend API URL.



\### Start the Development Server



```bash

npm run dev

```



Expected result:



```text

Local: http://localhost:5173

```



The frontend requires a reachable backend API through `VITE\\\_API\\\_URL`.



\---



\## 6. Build Command



Create a production build:



```bash

npm run build

```



Expected result:



```text

dist/

```



The `dist/` folder contains compiled static frontend assets.



The `dist/` folder should not be committed to Git.



\---



\## 7. Test Command



Run frontend tests:



```bash

npm test

```



If the project uses a different test script, confirm it in `package.json`.



Recommended test script:



```json

{

\&#x20; "scripts": {

\&#x20;   "test": "vitest"

\&#x20; }

}

```



Expected result:



```text

All frontend tests pass.

```



\---



\## 8. Docker Usage



\### Build the Frontend Image Locally



```bash

docker build -t zuri-market-frontend:local .

```



\### Run the Frontend Container Locally



```bash

docker run -p 8080:80 zuri-market-frontend:local

```



Expected result:



```text

Frontend is available at http://localhost:8080

```



\### DockerHub Image Naming



Recommended image name:



```text

temiayo/zuri-market-frontend

```



Recommended tag pattern:



| Tag            | Purpose                            |

| -------------- | ---------------------------------- |

| `latest`       | Most recent successful build       |

| `<commit-sha>` | Traceable build from GitHub commit |



Example build commands:



```bash

docker build -t temiayo/zuri-market-frontend:latest .

docker build -t temiayo/zuri-market-frontend:<commit-sha> .

```



\---



\## 9. CI/CD Behavior



The frontend is deployed through the GitHub Actions DevSecOps workflow.



| Pipeline Step | Purpose                      | Expected Result        |

| ------------- | ---------------------------- | ---------------------- |

| Checkout      | Pull repository code         | Source code available  |

| Install       | Install dependencies         | Dependencies installed |

| Test          | Run frontend tests           | Tests pass             |

| Build         | Compile assets               | `dist/` created        |

| Security scan | Check dependencies and image | No critical issues     |

| Docker build  | Build frontend image         | Image created          |

| Docker push   | Push image to DockerHub      | Image available        |

| Deploy        | Apply Kubernetes manifests   | Frontend updated       |

| Verify        | Check rollout and access     | Frontend reachable     |



A push to the `main` branch should trigger the pipeline automatically.



The pipeline should stop if frontend tests, security scans, Docker build, image push, or deployment verification fails.



\---



\## 10. Security Considerations



| Security Area        | Required Practice                    |

| -------------------- | ------------------------------------ |

| Environment files    | Never commit `.env`                  |

| Example variables    | Commit only `.env.example`           |

| API URL              | Use environment-specific values      |

| Frontend secrets     | Do not store secrets in browser code |

| Vite variables       | Treat `VITE\\\_` values as public       |

| Dependencies         | Scan with pipeline tooling           |

| Container image      | Scan before deployment               |

| Build output         | Do not commit `dist/`                |

| Registry credentials | Store in GitHub Actions Secrets      |



Important rule: frontend code runs in the browser. Any variable exposed through `VITE\\\_` can be viewed by users.



\---



\## 11. Troubleshooting



| Issue                           | Likely Cause            | Fix                   |

| ------------------------------- | ----------------------- | --------------------- |

| App will not start              | Dependencies missing    | Run `npm install`     |

| API calls fail                  | Wrong API URL           | Update `VITE\\\_API\\\_URL` |

| Store name missing              | Missing variable        | Add `VITE\\\_STORE\\\_NAME` |

| Build fails                     | Code issue              | Run build locally     |

| Docker build fails              | Dockerfile issue        | Review build logs     |

| Blank page after deploy         | Routing issue           | Check browser console |

| Container starts but page fails | Nginx issue             | Review `nginx.conf`   |

| Pipeline install fails          | Dependency mismatch     | Check lock file       |

| Pipeline scan fails             | Vulnerability found     | Review scan logs      |

| Rollout fails                   | Image or manifest issue | Describe the pod      |



\### Useful Local Commands



```bash

npm install

npm run dev

npm run build

npm test

```



\### Useful Docker Commands



```bash

docker build -t zuri-market-frontend:local .

docker run -p 8080:80 zuri-market-frontend:local

docker ps

docker logs <container-id>

```



\### Useful Kubernetes Commands



```bash

kubectl get pods

kubectl get deployments

kubectl get svc

kubectl describe pod <pod-name>

kubectl logs <pod-name>

kubectl rollout status deployment/<frontend-deployment-name>

```



\---



\## 12. Evidence Checklist



| Evidence Item           | Command or Screenshot | Expected Result       |

| ----------------------- | --------------------- | --------------------- |

| Dependencies installed  | `npm install`         | Install completes     |

| Dev server runs         | `npm run dev`         | Local URL shown       |

| Local `.env` exists     | Screenshot            | Variables present     |

| `.env.example` exists   | Screenshot            | Placeholders only     |

| Production build works  | `npm run build`       | `dist/` created       |

| Tests pass              | `npm test`            | Tests pass            |

| Docker image builds     | `docker build`        | Image created         |

| Container runs locally  | `docker run`          | App loads locally     |

| CI/CD job passes        | Actions screenshot    | Job succeeds          |

| DockerHub image exists  | DockerHub screenshot  | Image tag visible     |

| Kubernetes pod runs     | `kubectl get pods`    | Pod is running        |

| Frontend service exists | `kubectl get svc`     | Service available     |

| Frontend is accessible  | Browser screenshot    | Zuri Market loads     |

| No `.env` committed     | GitHub search         | No real secrets found |



\---



\## Final Notes



This frontend README helps a new engineer understand, configure, run, test, build, containerise, and troubleshoot the Zuri Market frontend in under 30 minutes.



Keep this file updated whenever the frontend structure, scripts, environment variables, Dockerfile, or deployment workflow changes.



