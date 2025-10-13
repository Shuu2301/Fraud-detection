FROM apache/spark:3.5.0

USER root

WORKDIR /app

# Set Java environment variables
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

# Ensure Java binaries are accessible to all users
RUN chmod -R 755 /opt/java/openjdk

# Create Ivy cache directory for spark user and set permissions
RUN mkdir -p /home/spark/.ivy2/cache && \
    chown -R spark:spark /home/spark/.ivy2 && \
    chmod -R 755 /home/spark/.ivy2

RUN pip install --no-cache-dir streamlit pandas plotly pyspark==3.5.0

USER spark

# Ensure Java is available to spark user
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

# Set Spark to use local Ivy cache
ENV SPARK_HOME=/opt/spark
ENV PATH=$SPARK_HOME/bin:$PATH

COPY infra/streamlit/app.py /app/app.py

EXPOSE 8501

CMD ["streamlit", "run", "app.py","--server.port=8501", "--server.address=0.0.0.0"]