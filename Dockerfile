# docker of RoseTTAFold

ARG CUDA=11.0
FROM nvidia/cuda:${CUDA}-base
# FROM directive resets ARGS, so we specify again (the value is retained if
# previously set).
ARG CUDA

# Use bash to support string substitution.
SHELL ["/bin/bash", "-c"]

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      build-essential \
      cmake \
      cuda-command-line-tools-${CUDA/./-} \
      git \
      hmmer \
      kalign \
      tzdata \
      wget \
    && rm -rf /var/lib/apt/lists/*


RUN git clone https://github.com/RosettaCommons/RoseTTAFold.git &&\
    cd RoseTTAFold

# Install Miniconda package manger.
RUN wget -q -P /tmp \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh &&\
    bash /tmp/Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda &&\
    rm /tmp/Miniconda3-latest-Linux-x86_64.sh

# Install conda packages.
ENV PATH="/opt/conda/bin:$PATH"
RUN conda update -qy conda &&\
    cudatoolkit==${CUDA}.3


WORKDIR /RoseTTAFold

# create conda environment for RoseTTAFold
# If your NVIDIA driver compatible with cuda11
#COPY RoseTTAFold-linux.yml /
RUN conda env create -f /RoseTTAFold/RoseTTAFold-linux.yml


# create conda environment for pyRosetta folding & running DeepAccNet
#COPY folding-linux.yml /
RUN conda env create -f /RoseTTAFold/folding-linux.yml

# Download network weights (under Rosetta-DL Software license -- please see below)
RUN wget -q -P /RoseTTAFold https://files.ipd.uw.edu/pub/RoseTTAFold/weights.tar.gz &&\
    tar xfz /RoseTTAFold/weights.tar.gz

# Download and install third-party software if you want to run the entire modeling script (run_pyrosetta_ver.sh)
#COPY install_dependencies.sh /
RUN /RoseTTAFold/install_dependencies.sh


# ENTRYPOINT [" "]

CMD ["/bin/sh"]
