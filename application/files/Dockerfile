FROM python

ARG MONGODB_IP

RUN apt-get update
RUN apt-get install -y git
RUN pip install flask pymongo

ADD ./FlaskWithMongoDB FlaskWithMongoDB

WORKDIR FlaskWithMongoDB
RUN sed -i "s/127.0.0.1/$MONGODB_IP/g" app.py
RUN sed -i "s/app.run()/app.run(debug=True, host='0.0.0.0')/g" app.py

CMD ["python", "app.py"]
