FROM quay.io/cybozu/ubuntu:20.04
RUN apt-get update && apt-get upgrade -y && apt-get install git autoconf make build-essential gawk python3  automake gcc perl zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev libncurses5-dev bcftools tabix -y
RUN apt-get install vim python3-pip -y 
RUN git clone https://github.com/slowkoni/rfmix.git && cd rfmix && autoreconf --force --install && ./configure && make && cp rfmix /bin/ && cd / && rm -rf /rfmix
RUN git clone https://github.com/Atkinson-Lab/Tractor.git 
RUN apt-get install python3 -y
RUN pip install hail
RUN apt install openjdk-8-jdk -y
RUN pip install ipython
RUN git clone https://github.com/Atkinson-Lab/Tractor-tutorial.git
RUN apt-get install unzip p7zip-full p7zip-rar wget -y
RUN wget -c https://mathgen.stats.ox.ac.uk/genetics_software/shapeit/shapeit.v2.r904.glibcv2.12.linux.tar.gz && tar -xzf shapeit.v2.r904.glibcv2.12.linux.tar.gz && cp shapeit.v2.*/bin/shapeit /bin/ && rm -rf shapeit.v2.*/ shapeit.v2.r904.glibcv2.12.linux.tar.gz
RUN pip install statsmodels
RUN apt-get install r-base r-base-dev -y
RUN R -e "install.packages('qqman')"
RUN R -e "install.packages('ggplot2')"
#RUN cd Tractor-tutorial && rm -f tutorial-data.zip && wget -c https://media.githubusercontent.com/media/Atkinson-Lab/Tractor-tutorial/main/tutorial-data.zip && unzip tutorial-data.zip
