FROM debian:jessie
MAINTAINER Jakub Matjanowski "kuba@matjanowski.pl"

ARG OPENCV_VERSION="3.2.0"

# install dependencies
RUN apt-get update
RUN apt-get install -y libopencv-dev yasm libjpeg-dev libjasper-dev libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev libv4l-dev python-dev python-numpy libtbb-dev libqt4-dev libgtk2.0-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev x264 v4l-utils pkg-config
RUN apt-get install -y curl build-essential checkinstall cmake unzip libunwind8 gettext

# download opencv
RUN curl -sL https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip
RUN unzip $OPENCV_VERSION.zip /tmp/opencv
RUN rm $OPENCV_VERSION.zip
RUN curl -sL https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.zip
RUN unzip $OPENCV_VERSION.zip /tmp/opencv_contrib
RUN rm $OPENCV_VERSION.zip

RUN mkdir -p /tmp/opencv-$OPENCV_VERSION/build

WORKDIR /tmp/opencv-$OPENCV_VERSION/build

# install
RUN cmake -DWITH_FFMPEG=OFF -DOPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules -DWITH_OPENEXR=OFF -DCo -DBUILD_TIFF=OFF -DWITH_CUDA=OFF -DWITH_NVCUVID=OFF -DBUILD_PNG=OFF ../opencv
RUN make
RUN make install

# configure
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf
RUN ldconfig
RUN ln /dev/null /dev/raw1394 # hide warning - http://stackoverflow.com/questions/12689304/ctypes-error-libdc1394-error-failed-to-initialize-libdc1394

# download & install dotnet
RUN curl -sSL -o dotnet.tar.gz https://go.microsoft.com/fwlink/?linkid=843453
RUN mkdir -p /opt/dotnet && tar zxf dotnet.tar.gz -C /opt/dotnet
RUN ln -s /opt/dotnet/dotnet /usr/local/bin

# cleanup package manager
RUN apt-get remove --purge -y curl build-essential checkinstall cmake
RUN apt-get autoclean && apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# prepare dir
RUN mkdir /source

VOLUME ["/source"]
WORKDIR /source
CMD ["bash"]