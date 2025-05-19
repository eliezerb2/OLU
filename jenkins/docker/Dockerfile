FROM jenkins/jenkins:lts

# Update packages to address vulnerabilities
USER root
RUN apt-get update && apt-get upgrade -y && apt-get clean
USER jenkins