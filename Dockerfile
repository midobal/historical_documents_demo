FROM nvidia/cuda:10.1-base-ubuntu18.04

##################
## Requirements ##
##################
SHELL ["/bin/bash", "-c"]
RUN apt-get update && apt-get install -y git wget && \
rm -rf /var/lib/apt/lists/*

########################
## Multimodal Wrapper ##
########################
RUN git clone https://github.com/lvapeab/multimodal_keras_wrapper.git /opt/multimodal_keras_wrapper
WORKDIR /opt/multimodal_keras_wrapper
RUN git checkout ca4a84838190da8fe83dd4a061f1545deb61e794 && echo \
"export PYTHONPATH=\$PYTHONPATH:/opt/multimodal_keras_wrapper/" >> ~/.bashrc

###########
## Keras ##
###########
RUN git clone https://github.com/MarcBS/keras.git /opt/keras
WORKDIR /opt/keras
RUN git checkout 144cc29a688c384967d1a3e05755d9991edacaea && echo \
"export PYTHONPATH=\$PYTHONPATH:/opt/keras/" >> ~/.bashrc

###############
## NMT-Keras ##
###############
RUN git clone https://github.com/midobal/nmt-keras.git /opt/nmt-keras
WORKDIR /opt/nmt-keras
RUN git checkout hd_demo

############################
## NMT-Keras Requirements ##
############################
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
bash /tmp/miniconda.sh -b -p /opt/miniconda && export PATH="/opt/miniconda/bin:$PATH" && \
conda config --set always_yes yes --set changeps1 no && conda update -q conda && conda init && \
conda install --file /opt/nmt-keras/req-travis-conda.txt && \
conda install mkl mkl-service && pip install -r /opt/nmt-keras/req-travis-pip.txt && \
pip install tensorflow==1.14.0 && rm /tmp/miniconda.sh

###################
## Launch server ##
###################
CMD export PATH="/opt/miniconda/bin:$PATH" && export PYTHONPATH=\$PYTHONPATH:/opt/multimodal_keras_wrapper/:/opt/keras/ && \
python ./demo-web/sample_server.py -v 2 --logging-level 2 --dataset ./model/Dataset_demo-web_esen.pkl \
--port=6542 --config ./model/config.pkl --models ./model/update_0 --changes LR=0.0
