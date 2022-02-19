ARG IMAGE=intersystemsdc/iris-community:latest
FROM $IMAGE

USER root
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
	libopencv-dev \
        python3-pip \
	python3-opencv \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/irisbuild
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisbuild
USER ${ISC_PACKAGE_MGRUSER}
ENV PIP_TARGET=${ISC_PACKAGE_INSTALLDIR}/mgr/python

RUN pip3 install tensorflow && \
    pip3 install numpy \
        matplotlib \
        h5py && \
    pip3 install keras --no-deps

COPY src src
COPY Installer.cls Installer.cls
COPY module.xml module.xml
COPY iris.script iris.script

RUN iris start IRIS \
	&& iris session IRIS < iris.script \
    && iris stop IRIS quietly
