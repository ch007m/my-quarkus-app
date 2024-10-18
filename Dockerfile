
FROM maven:3.9.6 AS build

COPY pom.xml .
COPY src .
#COPY .mvn .
#COPY mvnw .
RUN ls -la
RUN mvn package

FROM registry.access.redhat.com/ubi8/openjdk-17:1.20

# We make four distinct layers so if there are application changes the library layers can be re-used
COPY --from=build --chown=185 target/quarkus-app/lib/ /deployments/lib/
COPY --from=build --chown=185 target/quarkus-app/*.jar /deployments/
COPY --from=build --chown=185 target/quarkus-app/app/ /deployments/app/
COPY --from=build --chown=185 target/quarkus-app/quarkus/ /deployments/quarkus/

EXPOSE 8080
USER 185
ENV JAVA_OPTS_APPEND="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"
ENV JAVA_APP_JAR="/deployments/quarkus-run.jar"

ENTRYPOINT [ "/opt/jboss/container/java/run/run-java.sh" ]

