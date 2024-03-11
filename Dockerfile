####################
### BUILD IMAGES ###
####################

# COMMON
FROM ubuntu:22.04 AS app_base
# Pre-reqs
RUN apt-get update && apt-get install --no-install-recommends -y \
    git vim build-essential python3-dev python3-venv python3-pip
# Instantiate venv and pre-activate
RUN pip3 install virtualenv
RUN virtualenv /venv
# Credit, Itamar Turner-Trauring: https://pythonspeed.com/articles/activate-virtualenv-dockerfile/
ENV VIRTUAL_ENV=/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip3 install --upgrade pip setuptools
# Copy and enable all scripts
COPY ./scripts /scripts
RUN chmod +x /scripts/*
### DEVELOPERS/ADVANCED USERS ###
# Clone oobabooga/text-generation-webui
RUN git clone https://github.com/oobabooga/text-generation-webui /src
# Use script to check out specific version
ARG VERSION_TAG
ENV VERSION_TAG=${VERSION_TAG}
RUN . /scripts/checkout_src_version.sh
# To use local source: comment out the git clone command then set the build arg `LCL_SRC_DIR`
#ARG LCL_SRC_DIR="text-generation-webui"
#COPY ${LCL_SRC_DIR} /src
#################################
# Copy source to app
RUN cp -ar /src /app


# NVIDIA-CUDA [Daily driver. Well done - you are the incumbent, Nvidia! Don't exploit your position.]
# Base
FROM app_base AS app_nvidia
# Install pytorch for CUDA 12.1
RUN pip3 install torch==2.2.1 torchvision==0.17.1 torchaudio==2.2.1 \
    --index-url https://download.pytorch.org/whl/cu121 
# Install oobabooga/text-generation-webui
RUN pip3 install -r /app/requirements.txt

# Extended
FROM app_nvidia AS app_nvidia_x
# Install extensions
RUN chmod +x /scripts/build_extensions.sh && \
    . /scripts/build_extensions.sh


# ROCM [Untested. Widen your hardware support, AMD!]
# Base
FROM app_base AS app_rocm
# Install pytorch for ROCM
RUN pip3 install torch==2.2.1 torchvision==0.17.1 torchaudio==2.2.1 \
    --index-url https://download.pytorch.org/whl/rocm5.6
# Install oobabooga/text-generation-webui
RUN pip3 install -r /app/requirements_amd.txt

# Extended
FROM app_rocm AS app_rocm_x
RUN chmod +x /scripts/build_extensions.sh && \
    . /scripts/build_extensions.sh


# ARC [Untested, no hardware. Give AMD and Nvidia an incentive to compete, Intel!]
# Base
FROM app_base AS app_arc
# Install oneAPI dependencies
RUN pip3 install dpcpp-cpp-rt==2024.0 mkl-dpcpp==2024.0
# Install libuv required by Intel-patched torch
# !!! Fails to build (stale repo) !!!
# RUN pip3 install pyuv
# Install pytorch for ARC
RUN pip3 install install torch==2.1.0a0 torchvision==0.16.0a0 torchaudio==2.1.0a0 \
    intel-extension-for-pytorch==2.1.10 \
    --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/
# Install oobabooga/text-generation-webui
RUN pip3 install -r /app/requirements_cpu_only.txt

# Extended
FROM app_arc AS app_arc_x
RUN chmod +x /scripts/build_extensions.sh && \
    . /scripts/build_extensions.sh


# CPU [Everyone can join in, as long as they have the patience.]
# Base
FROM app_base AS app_cpu
# Install pytorch for CPU
RUN pip3 install torch==2.2.1 torchvision==0.17.1 torchaudio==2.2.1 \
    --index-url https://download.pytorch.org/whl/cpu
# Install oobabooga/text-generation-webui
RUN pip3 install -r /app/requirements_cpu_only.txt

# Extended
FROM app_cpu AS app_cpu_x
# Install extensions
RUN chmod +x /scripts/build_extensions.sh && \
    . /scripts/build_extensions.sh


# APPLE [Not possible. Open up your graphics acceleration API, Apple!]


######################
### RUNTIME IMAGES ###
######################

# COMMON
FROM ubuntu:22.04 AS run_base
# Runtime pre-reqs
RUN apt-get update && apt-get install --no-install-recommends -y \
    python3-venv python3-dev git
# Copy app and src
COPY --from=app_base /app /app
COPY --from=app_base /src /src
# Instantiate venv and pre-activate
ENV VIRTUAL_ENV=/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
# Finalise app setup
WORKDIR /app
EXPOSE 7860
EXPOSE 5000
EXPOSE 5005
# Required for Python print statements to appear in logs
ENV PYTHONUNBUFFERED=1
# Force variant layers to sync cache by setting --build-arg BUILD_DATE
ARG BUILD_DATE
ENV BUILD_DATE=$BUILD_DATE
RUN echo "$BUILD_DATE" > /build_date.txt
ARG VERSION_TAG
ENV VERSION_TAG=$VERSION_TAG
RUN echo "$VERSION_TAG" > /version_tag.txt
# Copy and enable all scripts
COPY ./scripts /scripts
RUN chmod +x /scripts/*
# Run
ENTRYPOINT ["/scripts/docker-entrypoint.sh"]


# NVIDIA-CUDA
# Base
FROM run_base AS base-nvidia
# Copy venv
COPY --from=app_nvidia $VIRTUAL_ENV $VIRTUAL_ENV
# Variant parameters
RUN echo "Nvidia Base" > /variant.txt
ENV EXTRA_LAUNCH_ARGS=""
CMD ["python3", "/app/server.py"]

# Extended
FROM run_base AS default-nvidia
# Copy venv
COPY --from=app_nvidia_x $VIRTUAL_ENV $VIRTUAL_ENV
# Variant parameters
RUN echo "Nvidia Extended" > /variant.txt
ENV EXTRA_LAUNCH_ARGS=""
CMD ["python3", "/app/server.py"]


# ROCM
# Base
FROM run_base AS base-rocm
# Copy venv
COPY --from=app_rocm $VIRTUAL_ENV $VIRTUAL_ENV
# Variant parameters
RUN echo "ROCM Base" > /variant.txt
ENV EXTRA_LAUNCH_ARGS=""
CMD ["python3", "/app/server.py"]

# Extended
FROM run_base AS default-rocm
# Copy venv
COPY --from=app_rocm_x $VIRTUAL_ENV $VIRTUAL_ENV
# Variant parameters
RUN echo "ROCM Extended" > /variant.txt
ENV EXTRA_LAUNCH_ARGS=""
CMD ["python3", "/app/server.py"]


# ARC
# Base
FROM run_base AS base-arc
# Copy venv
COPY --from=app_arc $VIRTUAL_ENV $VIRTUAL_ENV
# Variant parameters
RUN echo "ARC Base" > /variant.txt
ENV EXTRA_LAUNCH_ARGS=""
CMD ["python3", "/app/server.py"]

# Extended
FROM run_base AS default-arc
# Copy venv
COPY --from=app_arc_x $VIRTUAL_ENV $VIRTUAL_ENV
# Variant parameters
RUN echo "ARC Extended" > /variant.txt
ENV EXTRA_LAUNCH_ARGS=""
CMD ["python3", "/app/server.py"]


# CPU
# Base
FROM run_base AS base-cpu
# Copy venv
COPY --from=app_cpu $VIRTUAL_ENV $VIRTUAL_ENV
# Variant parameters
RUN echo "CPU Base" > /variant.txt
ENV EXTRA_LAUNCH_ARGS=""
CMD ["python3", "/app/server.py"]

# Extended
FROM run_base AS default-cpu
# Copy venv
COPY --from=app_cpu_x $VIRTUAL_ENV $VIRTUAL_ENV
# Variant parameters
RUN echo "CPU Extended" > /variant.txt
ENV EXTRA_LAUNCH_ARGS=""
CMD ["python3", "/app/server.py"]
