Creating a Docker container for HippoCMS
===================================
##Introduction
Don't we all know [Docker](https://www.docker.com/) by now? In short, Docker is a so called "container solution", which you can use to create application containers. Such a container is constructed from a base image and provisioned with e.g. an application and its configuration files. Unlike VM-based solutions, where a guest operating system runs fully independent of the host operating system using a hypervisor, Docker does not rely on a hypervisor to start your containers. Instead, Docker containers are managed by the Docker Engine. As Docker itself best [describes](https://www.docker.com/whatisdocker/) it, the Docker Engine runs your containers as an isolated process in userspace on the host operating system, sharing the kernel with other containers. Thus, it enjoys the resource isolation and allocation benefits of VMs but is much more portable and efficient.

OneHippo provides a nice demonstration of HippoCMS by providing the GoGreen community and enterprise demo. This lab will focus on creating a Docker image, containing a fully functional Hippo GoGreen demonstration suite (or any other HippoCMS implementation). I'll be focusing on developing, shipping and running a Docker image for Hippo GoGreen. 

####Lab prerequisites
To get started with this lab, make sure you've installed Docker on your local system. To install Docker, follow the [installation instructions](https://docs.docker.com/installation/#installation) provided by Docker.

----
##Putting Hippo in a Docker container
###Step 1 - Developing the HippoCMS Docker image
First we need to create a Docker image, which is later on used to start a container. An image is described by a so called "Dockerfile", providing a specification and bootstrap instructions for your container. The Dockerfile below covers all the necessary instructions to get Hippo GoGreen up and running in a container. In short:

 - the image is fired up using an Ubuntu 14.04 base image
 - the image is provisioned with some packages required to install and run HippoCMS
 - HippoCMS is retrieved from the \$HIPPO_URL and installed in the \$HIPPO_FOLDER in the image
 
Finally, we instruct Docker to expose port 8080 to the host system when an instance of this image is started, allowing us to interact with HippoCMS. We bind the startup script of Apache Tomcat to be the default execution of this image, such that HippoCMS is automatically started.

To proceed the lab, store the Dockerfile below in a work folder on your harddrive and save it as "Dockerfile".

```
# Generic Hippo Docker image
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

# Install packages required to install Hippo CMS
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java7-installer
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java7-set-default
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y dos2unix
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y unzip

# Install Hippo CMS, retrieving the GoGreen demonstration from the $HIPPO_URL and putting it under $HIPPO_FOLDER
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
```

###Step 2 - Creating the HippoCMS Docker image
Having the Dockerfile in your work folder, we instruct the Docker Engine to actually create an image out of it. In the same folder where our Dockerfile resides, we execute the following command, requiring root level access:

```sudo docker build -t="hippo/demo" .```

This tells the Docker Engine to create a new image from the Dockerfile in your work folder and store it in the (local) Docker image repository with "hippo/demo" as its image tag.

###Step 3 - Running the HippoCMS image in a new container
Allright, we've described the image source and created an actual image which is stored in our Docker image repository. Let's fire up a new container bootstrapped from this image, by executing the following command, requiring root level access:

```sudo docker run -p 8080:8080 hippo/demo```

This tells the Docker Engine to start a new container using the "hippo/demo" image from the local image repository, redirecting port 8080 on the host system to port 8080 in the container. 

###Step 4 - Observe Docker running your Hippo GoGreen
After startup has completed, we can use HippoCMS from the host system as if it were installed **on** the host system. Since we've exposed 8080 in the container (remember your Dockerfile), and we've instructed Docker to redirect port 8080 (Step 3), the host system its port 8080 is bound to the Apache Tomcat in the container. 

Thus, to use HippoCMS from the host system, browse to [http://localhost:8080/site](http://localhost:8080/site) and [http://localhost:8080/cms](http://localhost:8080/cms) and observe GoGreen from your host system, running in a Docker container!

##Conclusion
This lab illustrated that Docker, as a container solution, can be used to create a lightweight and portable Hippo GoGreen demonstration container. One of the advantages is that we can create multiple images from the same Dockerfile. This can come in quite handy if you're up for multiple demonstrations, requiring multiple GoGreen instances. Especially in concurrent demonstration cycles, where each instance requires a different setup or content, Docker simplifies the process of setting up multiple GoGreen's. Also it provides a way to easily get a portable version of GoGreen up and running quite fast. 

Hopefully I've showed you how easy it is to wrap HippoCMS in a Docker image and use it to your needs. Next step would be for OneHippo to start providing out-of-the-box Docker images :).

