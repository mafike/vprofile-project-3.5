FROM tomcat:8-jre11
RUN rm -rf /usr/local/tomcat/webapps/*
ARG WAR_FILE=target/*.war
COPY ${WAR_FILE} /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8081
CMD ["catalina.sh", "run"]