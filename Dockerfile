FROM python:3.9-alpine3.13
#Maintainer of image
LABEL maintainer="IssamLynx"

#do not buffer logs and outputs and print them directly to user
ENV PYTHONUNBUFFERED 1

#copy requirements.txt to tmp folder in the docker image
COPY ./requirements.txt /tmp/requirements.txt

COPY ./requirements.dev.txt /tmp/requirements.dev.txt

#cpy app directory to docker image
COPY ./app /app
# define the working directory of a Docker container at any given time
WORKDIR /app
#port to run docker image
EXPOSE 8000

#by default we are not in dev environement
ARG DEV=false
#creating env, installing requirements.txt, free docker image before ending and allow normal users to run docker image
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    # add posgresql client to run postgresql
    apk add --update --no-cache postgresql-client && \
    # dependencies for instaling postgresql
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

#adding system path
ENV PATH="/py/bin:$PATH"

#defining user
USER django-user