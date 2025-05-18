# Nexus Repository Helm/Kubernetes Automation

This project automates the deployment and management of a Nexus repository using Docker, Helm, and Kubernetes. It includes scripts for admin password automation, lifecycle management, and VS Code tasks for a streamlined developer experience.

## Project Structure

```
nexus/
├── docker/
│   ├── Dockerfile            # Build custom Nexus image (if needed)
│   └── nexus-data/           # Persistent Nexus data (for local testing)
├── helm/
│   ├── Chart.yaml            # Helm chart definition
│   ├── values.yaml           # Helm values (image, resources, etc.)
│   ├── scripts/              # Bash scripts for admin automation
│   │   ├── check_nexus_ready.sh
│   │   ├── init_nexus.sh
│   │   ├── nexus_initial_login.sh
│   │   └── set_nexus_password.sh
│   └── templates/
│       ├── deployment.yaml
│       ├── nexus-scripts-configmap.yaml
│       ├── pvc.yaml
│       └── service.yaml
├── rancher/                  # (Optional) Legacy Docker Compose setup
│   └── set_admin_credentials.sh
└── README.md
```

## Quick Start (Helm & Kubernetes)

1. **Build the Docker Image (if using a custom image):**

   ```powershell
   # From the workspace root
   .\build-docker.ps1 -envFilePath .\nexus\docker\.env -dockerfilePath .\nexus\docker -imageTag nexus-repo
   ```

   > By default, the Helm chart uses the official `sonatype/nexus3` image. To use your custom image, set `image.repository: nexus-repo` in `values.yaml`.
   >
2. **Deploy Nexus with Helm:**

   ```powershell
   helm upgrade --install nexus-repo ./nexus/helm --values ./nexus/helm/values.yaml
   ```

   Or use the VS Code task: **Nexus - Start Repository**
3. **Tail Logs and Monitor:**
   Use the VS Code task **Nexus - Deploy and Tail Logs** to deploy and open log terminals automatically.
4. **Access Nexus:**
   Open [http://localhost:8081](http://localhost:8081) in your browser.
5. **Stop or Remove Nexus:**
   Use the VS Code tasks **Nexus - Stop Repository** or **Nexus - Stop All**.

## Script Automation

- All admin automation scripts are available in the running pod at `/scripts` (mounted from a ConfigMap).
- The container lifecycle `postStart` hook runs `/scripts/init_nexus.sh`, which:
  1. Waits for Nexus to be ready
  2. Performs initial admin login
  3. Sets the admin password
- Script output is logged to `/nexus-data/init_nexus.log` in the pod.

## Troubleshooting

- **Permission denied errors:**
  - Use `emptyDir` for testing, or ensure your PVC supports the correct permissions for the Nexus user.
- **Scripts not present in container:**
  - Ensure scripts are in `nexus/helm/scripts/` and referenced in the ConfigMap with the correct path.
  - Run `helm upgrade --install ...` and restart the pod after changes.
- **Check which image is running:**
  ```powershell
  kubectl get pod <pod-name> -o jsonpath="{.spec.containers[0].image}"
  ```

## Contributing

Feel free to submit issues or pull requests!
