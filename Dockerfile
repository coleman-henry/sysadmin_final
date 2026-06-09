# Inherit from an image with JRE already on it
FROM amazoncorretto:17-headless

WORKDIR /minecraft

# Get the server binary and acknowledge the eula
RUN yum install -y wget && \
  wget -O server.jar https://piston-data.mojang.com/v1/objects/84194a2f286ef7c14ed7ce0090dba59902951553/server.jar && \
  echo "eula=true" > eula.txt

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
# minecraft port
EXPOSE 25565
# server startup
ENTRYPOINT ["./entrypoint.sh"]