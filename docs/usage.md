# Home Lab Docker Usage

## Prerequisites

- Ensure Docker Desktop is installed on your Windows machine.
- Docker Desktop must be set to start automatically with Windows.

## Setting Docker Desktop to Autostart

To ensure Docker Desktop starts automatically with Windows:

1. Open Docker Desktop.
2. Click on the gear icon (Settings) in the top-right corner.
3. Navigate to the "General" tab.
4. Check the option "Start Docker Desktop when you log in".

## Starting the Services

To start the services defined in your `docker-compose.yaml` files, run the following command from the root directory of your project:

```sh
docker-compose up -d
```

## Stopping the Services

To stop the services, run the following command from the root directory of your project:

```sh
docker-compose down
```
