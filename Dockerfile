FROM openjdk:9-jre-slim
ARG DD_AGENT_IP
ENV DD_IP=${DD_AGENT_IP}

# copy over our app
WORKDIR /app
COPY build/libs/gs-spring-boot-docker-0.1.0.jar /app
# Might be hacky -- dunno
COPY datadog/dd-java-agent.jar /app

# Fix for https://stackoverflow.com/questions/6784463/error-trustanchors-parameter-must-be-non-empty
# CMD sudo /var/lib/dpkg/info/ca-certificates-java.postinst configure
# NOTE: @ckelner: https://github.com/docker-library/openjdk/issues/145 switch to slim

EXPOSE 8080

# use shell form of entrypoint rather than exec so we can take advantage of variables
ENTRYPOINT java -javaagent:/app/dd-java-agent.jar -Ddd.service.name=dd-java-apm-example-openjdk -Ddd.agent.host=$DD_IP -Ddatadog.slf4j.simpleLogger.defaultLogLevel=debug -jar /app/gs-spring-boot-docker-0.1.0.jar
