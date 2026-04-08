package com.mindskip.xzs.controller.student;


import com.mindskip.xzs.base.BaseApiController;
import com.mindskip.xzs.base.RestResponse;
import com.mindskip.xzs.service.FileUpload;
import com.mindskip.xzs.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.io.InputStream;


@RequestMapping("/api/student/upload")
@RestController("StudentUploadController")
public class UploadController extends BaseApiController {

    private final FileUpload fileUpload;
    private final UserService userService;

    @Autowired
    public UploadController(FileUpload fileUpload, UserService userService) {
        this.fileUpload = fileUpload;
        this.userService = userService;
    }


    @RequestMapping(value = "/image", method = RequestMethod.POST)
    @ResponseBody
    public RestResponse uploadImage(HttpServletRequest request) {
        try {
            MultipartHttpServletRequest multipartHttpServletRequest = (MultipartHttpServletRequest) request;
            MultipartFile multipartFile = multipartHttpServletRequest.getFile("file");
            if (multipartFile == null) {
                return RestResponse.fail(2, "请选择要上传的图片");
            }
            long attachSize = multipartFile.getSize();
            if (attachSize == 0) {
                return RestResponse.fail(2, "图片大小不能为0");
            }
            String imgName = multipartFile.getOriginalFilename();
            if (imgName == null || imgName.isEmpty()) {
                return RestResponse.fail(2, "图片名不能为空");
            }
            try (InputStream inputStream = multipartFile.getInputStream()) {
                String filePath = fileUpload.uploadFile(inputStream, attachSize, imgName);
                if (filePath == null) {
                    return RestResponse.fail(2, "图片上传失败");
                }
                userService.changePicture(getCurrentUser(), filePath);
                return RestResponse.ok(filePath);
            }
        } catch (Exception e) {
            return RestResponse.fail(2, e.getMessage());
        }
    }

    @RequestMapping(value = "/file", method = RequestMethod.POST)
    @ResponseBody
    public RestResponse uploadFile(HttpServletRequest request) {
        try {
            MultipartHttpServletRequest multipartHttpServletRequest = (MultipartHttpServletRequest) request;
            MultipartFile multipartFile = multipartHttpServletRequest.getFile("file");
            if (multipartFile == null) {
                return RestResponse.fail(2, "请选择要上传的文件");
            }
            long attachSize = multipartFile.getSize();
            if (attachSize == 0) {
                return RestResponse.fail(2, "文件大小不能为0");
            }
            String fileName = multipartFile.getOriginalFilename();
            if (fileName == null || fileName.isEmpty()) {
                return RestResponse.fail(2, "文件名不能为空");
            }
            try (InputStream inputStream = multipartFile.getInputStream()) {
                String filePath = fileUpload.uploadFile(inputStream, attachSize, fileName);
                if (filePath == null) {
                    return RestResponse.fail(2, "文件上传失败");
                }
                return RestResponse.ok(filePath);
            }
        } catch (Exception e) {
            return RestResponse.fail(2, e.getMessage());
        }
    }


}
