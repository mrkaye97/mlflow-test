FROM continuumio/miniconda3

ENV HOME /
WORKDIR $HOME
COPY . $HOME

RUN apt-get -y update && \
  apt-get -y upgrade && \
  apt-get install -y postgresql

RUN conda install -c anaconda pip && \
  pip install --upgrade pip && \
  pip install -r requirements.txt && \
  pwd && ls && ls home &&  \
  conda update -n base -c defaults conda && \
  conda env list && \
  pip freeze list  && \
  which mlflow

CMD mlflow ui \
  --host 0.0.0.0 \
  --port $PORT \
  --backend-store-uri $DB_URL \
  --default-artifact-root s3://cv-data-science/mlflow-test
