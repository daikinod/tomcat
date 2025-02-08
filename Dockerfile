# OpenJDK 23 と Tomcat 10.1 ベースのイメージを使用
FROM openjdk:23-slim

# 環境変数設定
ENV CATALINA_HOME=/usr/local/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

# 必要なパッケージのインストールとTomcatのセットアップ
RUN apt-get update && apt-get install -y --no-install-recommends wget ca-certificates \
    && wget --no-check-certificate https://downloads.apache.org/tomcat/tomcat-10/v10.1.34/bin/apache-tomcat-10.1.34.tar.gz -O /tmp/tomcat.tar.gz \
    && mkdir -p $CATALINA_HOME \
    && tar xvf /tmp/tomcat.tar.gz -C $CATALINA_HOME --strip-components=1 \
    && rm /tmp/tomcat.tar.gz \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# MySQL JDBCドライバーのダウンロードと配置
RUN wget --no-check-certificate https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.3.0.tar.gz -O /tmp/mysql-connector-java.tar.gz \
    && tar -xvzf /tmp/mysql-connector-java.tar.gz -C /tmp \
    && cp /tmp/mysql-connector-j-8.3.0/mysql-connector-j-8.3.0.jar $CATALINA_HOME/lib/ \
    && rm -rf /tmp/mysql-connector-java*

# デフォルトアプリケーションの削除
RUN rm -rf $CATALINA_HOME/webapps/*

# WebアプリケーションのファイルをTomcatにコピー
COPY app/src/main/webapp/ $CATALINA_HOME/webapps/ROOT/

# Javaサーブレット（コンパイル済みクラスファイル）をTomcatにコピー
COPY app/src/main/java/servlet /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/servlet

# ポート8080を開放
EXPOSE 8080

# Tomcatの起動
CMD ["catalina.sh", "run"]
