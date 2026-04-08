package com.mindskip.xzs.service.impl;

import com.mindskip.xzs.configuration.property.QnConfig;
import com.mindskip.xzs.configuration.property.SystemConfig;
import com.mindskip.xzs.service.FileUpload;
import com.google.gson.Gson;
import com.qiniu.common.QiniuException;
import com.qiniu.http.Response;
import com.qiniu.storage.Configuration;
import com.qiniu.storage.Region;
import com.qiniu.storage.UploadManager;
import com.qiniu.storage.model.DefaultPutRet;
import com.qiniu.util.Auth;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.InputStream;

@Service
public class FileUploadImpl implements FileUpload {
    private final Logger logger = LoggerFactory.getLogger(FileUpload.class);
    private final SystemConfig systemConfig;


    @Autowired
    public FileUploadImpl(SystemConfig systemConfig) {
        this.systemConfig = systemConfig;
    }

    @Override
    public String uploadFile(InputStream inputStream, long size, String fileName) {
        QnConfig qnConfig = systemConfig.getQn();
        if (qnConfig == null || qnConfig.getAccessKey() == null || qnConfig.getSecretKey() == null || qnConfig.getBucket() == null) {
            logger.error("七牛云配置缺失");
            return null;
        }
        
        Configuration cfg = new Configuration(Region.region2());
        UploadManager uploadManager = new UploadManager(cfg);
        Auth auth = Auth.create(qnConfig.getAccessKey(), qnConfig.getSecretKey());
        String upToken = auth.uploadToken(qnConfig.getBucket());
        try {
            Response response = uploadManager.put(inputStream, null, upToken, null, null);
            DefaultPutRet putRet = new Gson().fromJson(response.bodyString(), DefaultPutRet.class);
            logger.info("文件上传成功: {}", putRet.key);
            return qnConfig.getUrl() + "/" + putRet.key;
        } catch (QiniuException ex) {
            logger.error("文件上传失败: {}", ex.getMessage(), ex);
            try {
                logger.error("七牛云响应: {}", ex.response.bodyString());
            } catch (Exception e) {
                logger.error("获取七牛云响应失败", e);
            }
        } catch (Exception ex) {
            logger.error("文件上传异常: {}", ex.getMessage(), ex);
        }
        return null;
    }
}
