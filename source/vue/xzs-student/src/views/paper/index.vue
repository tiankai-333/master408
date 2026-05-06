<template>
  <div class="paper-container">
    <div class="paper-header">
      <div class="header-icon">
        <i class="el-icon-document-copy"></i>
      </div>
      <h2>试卷中心</h2>
      <p>选择科目和试卷类型，开始答题</p>
    </div>

    <div class="paper-content">
      <el-tabs tab-position="left" v-model="tabId" @tab-click="subjectChange" class="subject-tabs">
        <el-tab-pane :label="item.name" :key="item.id" :name="item.id" v-for="item in subjectList">
          <div class="tab-content">
            <div class="toolbar">
              <div class="paper-type-filter">
                <el-radio-group v-model="queryParam.paperType" size="medium" @change="paperTypeChange">
                  <el-radio-button v-for="item in paperTypeEnum" :key="item.key" :label="item.key">
                    <i class="el-icon-notebook-2"></i>
                    {{item.value}}
                  </el-radio-button>
                </el-radio-group>
              </div>
            </div>

            <el-table
              v-loading="listLoading"
              :data="tableData"
              fit
              highlight-current-row
              class="paper-table"
              :header-cell-style="{ background: '#f8f9fa', color: '#1f2f3d', fontWeight: '600' }"
            >
              <el-table-column prop="id" label="序号" width="100">
                <template slot-scope="{row, $index}">
                  <span class="row-index">{{ $index + 1 }}</span>
                </template>
              </el-table-column>
              <el-table-column prop="name" label="试卷名称">
                <template slot-scope="{row}">
                  <div class="paper-name">
                    <i class="el-icon-document"></i>
                    <span>{{ row.name }}</span>
                  </div>
                </template>
              </el-table-column>
              <el-table-column align="right" width="150">
                <template slot-scope="{row}">
                  <router-link target="_blank" :to="{path:'/do',query:{id:row.id}}">
                    <el-button type="primary" size="small" icon="el-icon-video-play" class="start-btn">
                      开始答题
                    </el-button>
                  </router-link>
                </template>
              </el-table-column>
            </el-table>

            <pagination
              v-show="total>0"
              :total="total"
              :background="false"
              :page.sync="queryParam.pageIndex"
              :limit.sync="queryParam.pageSize"
              @pagination="search"
              class="custom-pagination"
            />
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import Pagination from '@/components/Pagination'
import examPaperApi from '@/api/examPaper'
import subjectApi from '@/api/subject'

export default {
  components: { Pagination },
  data () {
    return {
      queryParam: {
        paperType: 1,
        subjectId: 0,
        pageIndex: 1,
        pageSize: 10
      },
      tabId: '',
      listLoading: true,
      subjectList: [],
      tableData: [],
      total: 0
    }
  },
  created () {
    this.initSubject()
  },
  methods: {
    initSubject () {
      let _this = this
      subjectApi.list().then(re => {
        _this.subjectList = re.response
        let subjectId = _this.subjectList[0].id
        _this.queryParam.subjectId = subjectId
        _this.tabId = subjectId.toString()
        _this.search()
      })
    },
    search () {
      this.listLoading = true
      examPaperApi.pageList(this.queryParam).then(data => {
        const re = data.response
        this.tableData = re.list
        this.total = re.total
        this.queryParam.pageIndex = re.pageNum
        this.listLoading = false
      })
    },
    paperTypeChange (val) {
      this.search()
    },
    subjectChange (tab, event) {
      this.queryParam.subjectId = Number(this.tabId)
      this.search()
    }
  },
  computed: {
    ...mapState('enumItem', {
      paperTypeEnum: state => state.exam.examPaper.paperTypeEnum
    })
  }
}
</script>

<style lang="scss" scoped>
.paper-container {
  background-color: #f5f7fa;
  min-height: calc(100vh - 70px);
  padding: 30px;
}

.paper-header {
  text-align: center;
  margin-bottom: 40px;
  padding: 40px 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px;
  color: #fff;

  .header-icon {
    width: 80px;
    height: 80px;
    margin: 0 auto 20px;
    background: rgba(255, 255, 255, 0.2);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;

    i {
      font-size: 36px;
      color: #fff;
    }
  }

  h2 {
    font-size: 32px;
    font-weight: 700;
    margin: 0 0 10px;
  }

  p {
    font-size: 16px;
    opacity: 0.9;
    margin: 0;
  }
}

.paper-content {
  background: #fff;
  border-radius: 16px;
  padding: 30px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.subject-tabs {
  height: 100%;

  ::v-deep .el-tabs__header {
    background: #f8f9fa;
    border-radius: 12px;
    padding: 15px 0;
    margin-right: 30px;
  }

  ::v-deep .el-tabs__item {
    height: 50px;
    line-height: 50px;
    font-size: 15px;
    color: #606266;
    padding: 0 30px;
    transition: all 0.3s;

    &:hover {
      color: #667eea;
    }

    &.is-active {
      color: #667eea;
      background: rgba(102, 126, 234, 0.1);
      font-weight: 600;
    }
  }

  ::v-deep .el-tabs__nav-wrap::after {
    display: none;
  }

  ::v-deep .el-tabs__content {
    padding: 0;
  }
}

.tab-content {
  padding: 0 10px;
}

.toolbar {
  margin-bottom: 25px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 10px;
}

.paper-type-filter {
  display: flex;
  justify-content: flex-start;

  ::v-deep .el-radio-group {
    display: flex;
    gap: 10px;
  }

  ::v-deep .el-radio-button {
    border-radius: 8px;
    overflow: hidden;

    &:first-child {
      border-radius: 8px;
    }

    &:last-child {
      border-radius: 8px;
    }

    .el-radio-button__inner {
      border: none;
      background: #fff;
      color: #606266;
      font-size: 14px;
      padding: 10px 20px;
      border-radius: 8px;
      transition: all 0.3s;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

      i {
        margin-right: 6px;
      }

      &:hover {
        background: rgba(102, 126, 234, 0.1);
        color: #667eea;
      }
    }
  }

  ::v-deep .el-radio-button__orig-radio:checked + .el-radio-button__inner {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: #fff;
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
  }
}

.paper-table {
  border-radius: 10px;
  overflow: hidden;

  ::v-deep .el-table__header {
    border-radius: 10px;
  }

  ::v-deep .el-table__body {
    tr {
      transition: all 0.3s;

      &:hover > td {
        background-color: #f8f9fa !important;
      }
    }

    td {
      border-bottom: 1px solid #f0f0f0;
    }
  }

  .row-index {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 28px;
    height: 28px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: #fff;
    border-radius: 50%;
    font-size: 13px;
    font-weight: 600;
  }

  .paper-name {
    display: flex;
    align-items: center;

    i {
      margin-right: 10px;
      color: #667eea;
      font-size: 18px;
    }

    span {
      color: #1f2f3d;
      font-weight: 500;
    }
  }

  .start-btn {
    border-radius: 20px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: none;
    padding: 8px 20px;
    font-size: 13px;

    i {
      margin-right: 5px;
    }

    &:hover {
      opacity: 0.9;
      transform: translateY(-1px);
    }
  }
}

.custom-pagination {
  margin-top: 30px;
  padding: 20px 0;
  text-align: center;

  ::v-deep .el-pagination {
    display: inline-flex;
    gap: 10px;

    .btn-prev, .btn-next {
      border-radius: 8px;
      background: #fff;
      border: 1px solid #dcdfe6;
      transition: all 0.3s;

      &:hover {
        color: #667eea;
        border-color: #667eea;
      }
    }

    .el-pager li {
      border-radius: 8px;
      background: #fff;
      border: 1px solid #dcdfe6;
      margin: 0 3px;
      transition: all 0.3s;

      &:hover {
        color: #667eea;
        border-color: #667eea;
      }

      &.active {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: #fff;
        border-color: #667eea;
      }
    }
  }
}

@media screen and (max-width: 768px) {
  .paper-container {
    padding: 15px;
  }

  .paper-header {
    padding: 30px 20px;

    h2 {
      font-size: 24px;
    }
  }

  .paper-content {
    padding: 15px;
  }

  .subject-tabs {
    ::v-deep .el-tabs__header {
      margin-right: 15px;
    }

    ::v-deep .el-tabs__item {
      font-size: 14px;
      padding: 0 20px;
    }
  }

  .paper-type-filter {
    ::v-deep .el-radio-button__inner {
      padding: 8px 12px;
      font-size: 13px;
    }
  }
}
</style>
