# Home Lab Docker Configuration

## Volume Configuration

When setting up your Docker volumes, it's important to configure the correct path for the Docker socket depending on your operating system.

### For Linux

Use the following volume configuration:

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

### For Windows

Use the following volume configuration:

```yaml
volumes:
  - //var/run/docker.sock:/var/run/docker.sock
```

Ensure that you update your `docker-compose.yaml` files accordingly based on the operating system you are using.

## Contralized Volume Storage

All Docker containers in the home lab will store their files in a centralized location specified by an environment variable. This ensures that all volumes are managed in one place.

### Configuration

Set the `DOCKER_VOLUMES` environment variable in your `.env` file to specify the path where all Docker volumes should be stored. For example:

```env
// filepath: /path/to/home-lab/docker/.env
DOCKER_VOLUMES=E:\\docker-volumes
```

This configuration will ensure that all Docker volumes are stored under `docker-volumes`. Each service can then use this path to store its data.

### Example Volume Configuration

Here is an example of how to configure a service to use the centralized volume storage:

```yaml
services:
  example_service:
    image: example/image:latest
    container_name: example_service
    restart: always
    volumes:
      - ${DOCKER_VOLUMES}/example_service_data:/data
```

This setup ensures that the `example_service` stores its data in `E:\docker-volumes\example_service_data.`
