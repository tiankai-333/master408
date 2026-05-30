package com.mindskip.xzs.viewmodel.student.dashboard;


import java.util.Date;
import java.util.List;

public class TaskItemVm {
    private Integer id;
    private String title;
    private Date createTime;
    private List<TaskItemPaperVm> paperItems;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public List<TaskItemPaperVm> getPaperItems() {
        return paperItems;
    }

    public void setPaperItems(List<TaskItemPaperVm> paperItems) {
        this.paperItems = paperItems;
    }
}
