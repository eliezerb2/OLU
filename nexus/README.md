# Nexus Repository on Rocky Linux

This project sets up a Nexus repository using a Docker container based on a Rocky Linux image. It is designed to run using Rancher Desktop, providing a simple and efficient way to manage your Nexus repository.

## Project Structure

```
nexus-rocky-project
├── docker
│   ├── Dockerfile          # Instructions to build the Nexus Docker image
│   └── nexus-data         # Directory for persistent Nexus data
├── rancher
│   └── docker-compose.yaml  # Configuration for running Nexus with Docker Compose
├── .vscode
│   ├── launch.json         # Debugging configuration
│   └── tasks.json          # Workspace tasks
└── README.md               # Project documentation
```

## Setup Instructions

1. **Clone the Repository**
   Clone this repository to your local machine.

   ```bash
   git clone <repository-url>
   cd nexus-rocky-project
   ```

2. **Build the Docker Image**
   Navigate to the `docker` directory and build the Docker image using the provided Dockerfile.

   ```bash
   cd docker
   docker build -t nexus-rocky .
   ```

3. **Run Nexus with Docker Compose**
   Navigate to the `rancher` directory and start the Nexus repository using Docker Compose.

   ```bash
   cd rancher
   docker-compose up -d
   ```

4. **Access Nexus**
   Once the container is running, you can access the Nexus repository by navigating to `http://localhost:8081` in your web browser.

## Usage

- To stop the Nexus repository, run:

  ```bash
  docker-compose down
  ```

- For persistent data, ensure that the `nexus-data` directory is properly mapped in the Docker Compose configuration.

## Additional Information

- For debugging, use the configurations provided in the `.vscode/launch.json` file.
- You can define custom tasks in the `.vscode/tasks.json` file to streamline your workflow.

Feel free to contribute to this project by submitting issues or pull requests!