FROM registry.cn-hangzhou.aliyuncs.com/mindskip/java:1.8.0

RUN mkdir -p /app /var/log/xzs
COPY xzs-3.9.0.jar /app/xzs-3.9.0.jar

EXPOSE 8000

CMD ["java", "-Duser.timezone=Asia/Shanghai", "-jar", "-Dspring.profiles.active=prod", "/app/xzs-3.9.0.jar"]
