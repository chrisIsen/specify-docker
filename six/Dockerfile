FROM openjdk:jre
ADD ./Specify_unix_64.sh /usr/src/specify/
ADD ./wait-for-it.sh /usr/src/specify/
WORKDIR /usr/src/specify
RUN chmod +x Specify_unix_64.sh
# run the installer quietly, using defaults, with progress logged to console
RUN ./Specify_unix_64.sh -q -console
RUN rm ./Specify_unix_64.sh
RUN apt-get update
RUN apt-get install libxxf86vm1
RUN ln -s /usr/local/Specify/ /opt/Specify
VOLUME /opt/Specify
CMD exec ./wait-for-it.sh --timeout=40 db:3306 --strict -- \
	Specify
