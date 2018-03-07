FROM openjdk:9-jre
ARG DD_AGENT_IP
ENV DD_IP=${DD_AGENT_IP}

# copy over our app
WORKDIR /app
COPY build/libs/gs-spring-boot-docker-0.1.0.jar /app
# Might be hacky -- dunno
COPY datadog/dd-java-agent.jar /app

EXPOSE 8080

# use shell form of entrypoint rather than exec so we can take advantage of variables
ENTRYPOINT java -javaagent:/app/dd-java-agent.jar -Ddd.service.name=dd-java-apm-example-openjdk -Ddd.agent.host=$DD_IP -Ddatadog.slf4j.simpleLogger.defaultLogLevel=debug -jar /app/gs-spring-boot-docker-0.1.0.jar
