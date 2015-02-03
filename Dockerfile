# Generic Hippo Docker container
FROM ubuntu:14.04
MAINTAINER Brian Snijders <brian@finalist.nl>

# Set environment variables
ENV PATH /srv/hippo/bin:$PATH
ENV HIPPO_FILE HippoCMS-GoGreen-Enterprise-7.9.4.zip
ENV HIPPO_FOLDER HippoCMS-GoGreen-Enterprise-7.9.4
ENV HIPPO_URL http://download.demo.onehippo.com/7.9.4/HippoCMS-GoGreen-Enterprise-7.9.4.zip

# Create the work directory for Hippo
RUN mkdir -p /srv/hippo

# Add Oracle Java Repositories
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common
RUN DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:webupd8team/java
RUN DEBIAN_FRONTEND=noninteractive apt-get update

# Approve license conditions for headless operation
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections

# Install packages required for Hippo CMS
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java7-installer
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java7-set-default
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y dos2unix
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y unzip

# Install Hippo CMS
RUN curl -L $HIPPO_URL -o $HIPPO_FILE
RUN unzip $HIPPO_FILE
RUN mv /$HIPPO_FOLDER/tomcat/* /srv/hippo
RUN chmod 700 /srv/hippo/* -R

# Replace DOS line breaks on Apache Tomcat scripts, to properly load JAVA_OPTS
RUN dos2unix /srv/hippo/bin/setenv.sh
RUN dos2unix /srv/hippo/bin/catalina.sh

# Expose ports
EXPOSE 8080

# Start Hippo
WORKDIR /srv/hippo/
CMD ["catalina.sh", "run"]
