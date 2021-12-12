FROM continuumio/miniconda3

LABEL maintainer "yennj12"

ENV HOME /
WORKDIR $HOME
COPY . $HOME

RUN apt-get -y update && apt-get -y upgrade && apt-get install -y sqlite3 libsqlite3-dev
RUN mkdir db && /usr/bin/sqlite3 /db/mlflow.db

RUN conda install -c anaconda pip && \
pip install --upgrade pip && \
pip install -r requirements.txt && \ 
pwd && ls && ls home &&  \ 
conda update -n base -c defaults conda && \ 
conda env list && \ 
pip freeze list  && \ 
which mlflow 

EXPOSE 5000

CMD mlflow ui --host 0.0.0.0 --backend-store-uri 'sqlite'