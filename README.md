# Simplified Datadog Java APM Example
A very simple Java application using Datadog APM w/ the Datadog `dd-trace-api`
as described in the [Datadog Java APM
docs](https://docs.datadoghq.com/tracing/languages/java/#trace-annotation).

This repo leverages Docker for ease of use.

# Noteworthy
- This small project is for demonstration purposes only.
- It does not make use any container orchestrator.
- It's original intent was to be used on a developer's local machine.
- It is not production grade.

# Prerequisites
- Install Java OpenJDK for your platform
- Install Docker for your platform

# Send APM Metrics to Datadog
## Run the Datadog Dockerized Agent
- Run to build the image: `docker build -t dd-agent ./agent/`
- Run the following, replacing `{your_api_key_here}` with your
own DD API key.
  ```
  docker run -d --rm --name dd-agent \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v /proc/:/host/proc/:ro \
    -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
    -e API_KEY={your_api_key_here} \
    -e DD_APM_ENABLED=true \
    -p 8126:8126/tcp \
    -e SD_BACKEND=docker \
    -e LOG_LEVEL=DEBUG \
    -e DD_LOGS_STDOUT=yes \
    -e DD_PROCESS_AGENT_ENABLED=true \
    dd-agent
  ```

## Run the Java example
- Run `./gradlew build` (or `gradlew.bat` if on windows)
- Set an environment variable with the DD docker agent IP: ```
  DD_AGENT_IP_ADDR=`docker inspect -f
  '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dd-agent`
```
- Run to build the docker image: `docker build -t dd-java-apm --build-arg DD_AGENT_IP=$DD_AGENT_IP_ADDR .`
- Run to start the container:
  ```
  docker run -d -p 8081:8080 --rm --name dd-java-apm dd-java-apm \
  -e TAGS=host:dd-java-apm-demo-openjdk,env:demo
  ```

## Additional Docker commands
- Run to see the containers running: `docker ps`
- Run to see container logs: `docker logs dd-java-apm`
- Run to get to bash prompt for the container: `docker exec -it dd-java-apm
/bin/bash`
- Run to stop the container: `docker stop dd-java-apm`
- Run to remove the container: `docker rm dd-java-apm`

## See APM in Datadog
- Hit these web urls locally to generate some APM metrics and traces:
    - http://localhost:8081
    - http://localhost:8081/sleepy
      - **Noteworthy**
        - As an unauthenticated GitHub request, you may see:
          ```
          {
            "message": "API rate limit exceeded for 76.97.244.208. (But here's the good news: Authenticated requests get a higher rate limit. Check out the documentation for more details.)",
            "documentation_url": "https://developer.github.com/v3/#rate-limiting"
          }
          ```
          Pretty quickly when executing `/lookup` -- this will result in a `500`
          from this application since it isn't doing any proper exception
          handling
- Visit [Datadog APM env:demo](https://app.datadoghq.com/apm/services?env=demo)
and the `dd-java-apm-example-openjdk` service should be listed.
