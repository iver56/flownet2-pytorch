FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

# CUDA-related environment variables
ENV CUDA_PATH /usr/local/cuda
ENV PATH ${CUDA_PATH}/bin:$PATH
ENV LD_LIBRARY_PATH ${CUDA_PATH}/bin64:${CUDA_PATH}/lib64:${CUDA_PATH}/lib64/stubs:$LD_LIBRARY_PATH

RUN ln -s ${CUDA_PATH}/lib64/stubs/libcuda.so ${CUDA_PATH}/lib64/stubs/libcuda.so.1

# Miniconda-related environment variables
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

# Install packages required for flownet2-pytorch and for installing miniconda 3
RUN apt-get update --fix-missing && \
    apt-get install -y \
        bzip2 \
        ca-certificates \
        curl \
        git \
        htop \
        openssh-server \
        rsync \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install miniconda 3
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN conda install pytorch==0.4.1 scipy scikit-image
RUN pip install torchvision cffi tensorboardX tqdm colorama==0.3.7 setproctitle pytz ipython

WORKDIR /usr/src/app

COPY . .

RUN bash install.sh

# Tini: A tiny but valid `init` for containers
ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
