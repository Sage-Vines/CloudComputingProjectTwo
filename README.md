# Local Cloud With Terraform & Docker

This repo as a small “local cloud” that Terraform operates. It is just Terraform, Docker provider, and config files that turn into a note-taking app with a modern UI, a Python API, and a Postgres database.

- **Frontend (Nginx & static SPA)** – services/frontend/site holds the HTML/CSS/JS bundle. Terraform mounts that folder along with default.conf into the stock nginx:alpine image. The app lets you create, edit, and delete notes.
- **Backend (Python)** – services/backend/app.py is a HTTP server which is free from frameworks. Terraform bind-mounts folder inside python:3.11-slim, the start.sh script installs psycopg on boot, and the API exposes /api/notes for GET/POST/PUT/DELETE with auto table creation.
- **Postgres Database** – real postgres:15-alpine, credentials arrive via variables, and the module attaches a named Docker volume so data sticks around between runs.
- **Custom Docker network** – local-cloud keeps every container on the same subnet so service discovery is predictable.

## Requirements Satisfied

- **Separate Modules** – network, database, backend, and frontend are their own Terraform modules, so root config just wires them together.
- **docker_image / docker_container / docker_network** – each module uses the right resource types straight from the Docker provider, satisfying the spec.
- **Secrets** – database_password is only sensitive value and you feed it through terraform.tfvars Nothing secret lives within actual code.
- **Frontend** – module variables pin port mapping, so SPA is always reachable on localhost:8080 without extra flags.
- **Custom network & dependency graph** – every container joins module.network.name, and Terraform’s depends_on keeps creation order tidy.
- **Enhancement** – database module provisions postgres-data Docker volume for persistence, so your carefully typed notes don’t disappear when containers restart. Also, UI and backend is customized to be a handy note-taking application. I also included reverse-proxying as a little bonus.

## Everything within the Repository

- `main.tf`, `variables.tf`, `outputs.tf` – what orchesrates everything
- `modules/*` – one directory per component, each declaring its own provider requirements, inputs, and outputs.
- `services/frontend/default.conf` – small nginx config file which serves SPA from `/usr/share/nginx/html` and proxies `/api/*` back to Python in backend.
- `services/frontend/site/` – actual UI (HTML template, neon style, vanilla JavaScript logic with edit/delete buttons).
- `services/backend/app.py` & `start.sh` – API plus boot script that installs dependencies on the fly so Dockerfiles are not actually needed.
- `terraform.tfvars` – this file is created for password stashing.

## Setup of Terraform project

1. **First, you must install prerequisites**
   - Terraform >= 1.5
   - Docker Desktop or Engine running locally (I have Docker Desktop)
2. **Then, you must Configure secrets**
   - Copy snippet above into terraform.tfvars
   - Swap password for any password wanted
3. **Then, you must provision Terraform**
   ```powershell
   terraform init   # I use powershell
   terraform plan   # this is an optional step
   terraform apply
   ```
4. **Using the app**
   - Visit `http://localhost:8080`
   - You may add, edit, or delete notes; everything persists in Postgres instantly
   - Run docker ps to see the three containers on the local-cloud network
   - docker volume ls will list postgres-data, proving the enhancement is alive
5. **If you want to edit the code**
   - Change frontend files under services/frontend/site or backend code in services/backend
   - Re-run terraform apply and the containers restart with the new code because we bind-mount those folders

## If you want to clean up the code

```powershell
terraform destroy #Powershell command
```

- This command essentially tears down containers, network, and the pulled images related to the note-taking app. The postgres-data Docker volume intentionally sticks around so you can spin the stack back up without losing notes—delete it manually if you want a totally clean slate.
