ARG base_container=ubuntu:18.04
FROM $base_container
USER root

ARG build_dependences=true

RUN if $build_dependences ; then \
	useradd -d /cv cv ;\
	mkdir /cv; \
	chown -R cv:cv /cv ; \
	apt-get update ;\
	apt-get install build-essential ;\
	apt-get install -y software-properties-common ;\
	apt-get update  && apt-get install -y --no-install-recommends git wget unzip tmux pkg-config curl nano \
	cmake ffmpeg \
	libgl1-mesa-dev libavcodec-dev \
	libavutil-dev libavformat-dev \
	libswscale-dev libavdevice-dev \
	libdc1394-22-dev libraw1394-dev \
	libjpeg-dev libtiff5-dev \
	libopenexr-dev \
	libboost-all-dev libpcap-dev libssl-dev g++ ;\
	ldconfig ;\
	apt-get install -y python3.6 python3-pip ; \
	python3 -mpip install numpy ; \
	rm -rf /var/lib/apt/lists/* ; fi


RUN mkdir /cv/program

# OpenCV installation
ARG opencv_Path='/cv/program/opencv-3.4.11'
ARG opencv_contrib_Path='/cv/program/opencv_contrib-3.4.11'
ARG build_dependences=true

RUN mkdir $opencv_Path
RUN if $build_dependences ; then \
	wget https://github.com/opencv/opencv/archive/3.4.11.zip ; \
	unzip 3.4.11.zip -d /cv/program ;\
	rm 3.4.11.zip; \
	wget https://github.com/opencv/opencv_contrib/archive/3.4.11.zip ;\
	unzip 3.4.11.zip -d /cv/program ;\
	rm 3.4.11.zip; fi
RUN cd $opencv_Path
RUN mkdir $opencv_Path/build

WORKDIR $opencv_Path/build
RUN if $build_dependences ; then \
	cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local \
	-D OPENCV_GENERATE_PKGCONFIG=ON \
	-D OPENCV_EXTRA_MODULES_PATH=$opencv_contrib_Path/modules  .. ; \
	make -j7 ;\
	make install ; fi 

WORKDIR $opencv_Path/build
RUN if $build_dependences ; then \
	\echo "/usr/local/lib" >> /etc/ld.so.conf.d/opencv.conf; \
	ldconfig; fi

WORKDIR /cv
RUN ldconfig

#change the user
USER cv

COPY . /cv/program/cv
WORKDIR /cv/program/cv