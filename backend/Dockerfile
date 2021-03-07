FROM ubuntu:hirsute AS base
ENV DEBIAN_FRONTEND=noninteractive
ENV CONDA_DIR=/opt/conda
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH=${CONDA_DIR}/bin:${PATH}

# system packages installation
RUN apt update && apt install -y unzip ca-certificates curl libopenblas-dev libmagic1 libboost-all-dev libxrender-dev liblapack-dev git bzip2 cmake build-essential libsm6 libglib2.0-0 libgl1-mesa-glx libheif-dev libffi-dev swig --no-install-recommends
RUN mkdir -p /opt/conda && \
	curl -SL https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh -o ${CONDA_DIR}/miniforge.sh && \
	bash ${CONDA_DIR}/miniforge.sh -b -u -p ${CONDA_DIR} && \
	rm ${CONDA_DIR}/miniforge.sh
RUN bash -c "case \"`uname -m`\" in \"x86_64\") pip install torch==1.7.1+cpu torchvision==0.8.2+cpu -f https://download.pytorch.org/whl/torch_stable.html;; \"aarch64\") pip install torch==1.7.1 torchvision==0.8.2 -f https://torch.maku.ml/whl/stable.html;; esac"
RUN conda install -y numpy psycopg2 cython pandas scikit-learn=0.24.1 scikit-image=0.18.1 spacy=2.3.5 gevent=20.12.1 matplotlib=3.3.2

FROM base AS models
# pre trained models download
WORKDIR /data_models
RUN mkdir -p /data_models/places365/ && \
	mkdir -p /data_models/im2txt/ && \
	mkdir -p /root/.cache/torch/hub/checkpoints/
RUN curl -SL https://s3.eu-central-1.amazonaws.com/ownphotos-deploy/places365_model.tar.gz | tar -zxC /data_models/places365/
RUN curl -SL https://s3.eu-central-1.amazonaws.com/ownphotos-deploy/im2txt_model.tar.gz | tar -zxC /data_models/im2txt/
RUN curl -SL https://s3.eu-central-1.amazonaws.com/ownphotos-deploy/im2txt_data.tar.gz | tar -zxC /data_models/im2txt/
RUN curl -SL https://download.pytorch.org/models/resnet152-b121ed2d.pth -o /root/.cache/torch/hub/checkpoints/resnet152-b121ed2d.pth
# actual project

FROM base AS pybuilder
RUN pip install -v --install-option="--no" --install-option="DLIB_USE_CUDA" --install-option="--no" --install-option="USE_AVX_INSTRUCTIONS" --install-option="--no" --install-option="USE_SSE4_INSTRUCTIONS" dlib
WORKDIR /faiss
RUN git clone https://github.com/facebookresearch/faiss.git /faiss
RUN cmake -B build . -DFAISS_ENABLE_GPU=OFF -DFAISS_ENABLE_PYTHON=ON -DFAISS_OPT_LEVEL=generic
RUN make -C build -j faiss
RUN make -C build -j swigfaiss
RUN (cd build/faiss/python && python setup.py install)

FROM base AS final
ARG DEBUG
WORKDIR /code
RUN git clone https://github.com/LibrePhotos/librephotos .
# RUN sed -i "s/spacy==2.3.2/spacy==2.3.5/" requirements.txt && \
# 	sed -i "s/sklearn==0.0/scikit-learn==0.24.1/" requirements.txt && \
# 	sed -i "s/gevent==20.9.0/gevent==20.12.1/" requirements.txt && \
# 	sed -i "s/dlib==19.21.1/dlib>=19.21.0/" requirements.txt && \
# 	sed -i "s/scipy==1.5.3/scipy==1.6.0/" requirements.txt && \
# 	sed -i "s/pytz==2020.1/pytz>=2021.1/" requirements.txt && \
# 	sed -i "s/faiss-cpu==1.7.0/faiss>=1.7.0/" requirements.txt && \
COPY --from=pybuilder /opt/conda/lib/python3.8/site-packages/*dlib* /opt/conda/lib/python3.8/site-packages/faiss* /opt/conda/lib/python3.8/site-packages/
RUN sed -i "/spacy==2.3.2/d" requirements.txt && \
	sed -i "/sklearn==0.0/d" requirements.txt && \
	sed -i "/gevent==20.9.0/d" requirements.txt && \
	sed -i "s/dlib==19.21.1/dlib>=19.21.1/" requirements.txt &&  \
	sed -i "/scipy==1.5.3/d" requirements.txt && \
	sed -i "s/pytz==2020.1/pytz>=2021.1/" requirements.txt && \
	sed -i "s/Pillow==8.1.0/Pillow>=8.1.2/" requirements.txt && \
	sed -i "/faiss-cpu==1.7.0/d" requirements.txt && \
	pip install -r requirements.txt
RUN python -m spacy download en_core_web_sm
COPY --from=models /data_models /data_models
COPY --from=models /root/.cache /root/.cache
RUN unzip /opt/conda/lib/python3.8/site-packages/faiss*.egg -d /opt/conda/lib/python3.8/site-packages/
EXPOSE 8001

COPY entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
