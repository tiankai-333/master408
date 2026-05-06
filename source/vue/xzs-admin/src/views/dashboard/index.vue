<template>
  <div class="dashboard-container">
    <div class="dashboard-header">
      <h2>仪表盘</h2>
      <p>欢迎使用 408master 管理后台，以下是系统数据概览</p>
    </div>

    <el-row :gutter="20" class="panel-group">
      <el-col :xs="12" :sm="12" :lg="6" class="card-panel-col">
        <div class="card-panel">
          <div class="card-panel-icon-wrapper icon-people">
            <svg-icon icon-class="exam" class-name="card-panel-icon"/>
          </div>
          <div class="card-panel-description">
            <div class="card-panel-text">试卷总数</div>
            <count-to :start-val="0" :end-val="examPaperCount" :duration="2600" class="card-panel-num" v-loading="loading"/>
          </div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="12" :lg="6" class="card-panel-col">
        <div class="card-panel">
          <div class="card-panel-icon-wrapper icon-message">
            <svg-icon icon-class="question" class-name="card-panel-icon"/>
          </div>
          <div class="card-panel-description">
            <div class="card-panel-text">题目总数</div>
            <count-to :start-val="0" :end-val="questionCount" :duration="3000" class="card-panel-num" v-loading="loading"/>
          </div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="12" :lg="6" class="card-panel-col">
        <div class="card-panel">
          <div class="card-panel-icon-wrapper icon-shopping">
            <svg-icon icon-class="doexampaper" class-name="card-panel-icon"/>
          </div>
          <div class="card-panel-description">
            <div class="card-panel-text">答卷总数</div>
            <count-to :start-val="0" :end-val="doExamPaperCount" :duration="3600" class="card-panel-num" v-loading="loading"/>
          </div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="12" :lg="6" class="card-panel-col">
        <div class="card-panel">
          <div class="card-panel-icon-wrapper icon-money">
            <svg-icon icon-class="doquestion" class-name="card-panel-icon"/>
          </div>
          <div class="card-panel-description">
            <div class="card-panel-text">答题总数</div>
            <count-to :start-val="0" :end-val="doQuestionCount" :duration="3200" class="card-panel-num" v-loading="loading"/>
          </div>
        </div>
      </el-col>
    </el-row>

    <div class="echarts-section">
      <div id="echarts-moth-user" style="width: 100%;height:360px;" v-loading="loading"/>
    </div>
    <div class="echarts-section">
      <div id="echarts-moth-question" style="width: 100%;height:360px;" v-loading="loading"/>
    </div>
  </div>
</template>

<script>
import resize from './components/mixins/resize'
import CountTo from 'vue-count-to'
import dashboardApi from '@/api/dashboard'
export default {
  mixins: [resize],
  components: {
    CountTo
  },
  data () {
    return {
      examPaperCount: 0,
      questionCount: 0,
      doExamPaperCount: 0,
      doQuestionCount: 0,
      echartsUserAction: null,
      echartsQuestion: null,
      loading: false
    }
  },
  mounted () {
    // eslint-disable-next-line no-undef
    this.echartsUserAction = echarts.init(document.getElementById('echarts-moth-user'), 'macarons')
    // eslint-disable-next-line no-undef
    this.echartsQuestion = echarts.init(document.getElementById('echarts-moth-question'), 'macarons')
    let _this = this
    this.loading = true
    dashboardApi.index().then(re => {
      let response = re.response
      _this.examPaperCount = response.examPaperCount
      _this.questionCount = response.questionCount
      _this.doExamPaperCount = response.doExamPaperCount
      _this.doQuestionCount = response.doQuestionCount
      _this.echartsUserAction.setOption(this.option('用户活跃度', '{b}日{c}度', response.mothDayText, response.mothDayUserActionValue))
      _this.echartsQuestion.setOption(this.option('题目月数量', '{b}日{c}题', response.mothDayText, response.mothDayDoExamQuestionValue))
      this.loading = false
    })
  },
  methods: {
    option (title, formatter, label, vaule) {
      return {
        title: {
          text: title,
          x: 'center'
        },
        tooltip: {
          trigger: 'item',
          formatter: formatter
        },
        xAxis: {
          type: 'category',
          data: label
        },
        grid: {
          left: 10,
          right: 10,
          bottom: 20,
          top: 30,
          containLabel: true
        },
        yAxis: {
          type: 'value'
        },
        series: [{
          data: vaule,
          type: 'line'
        }]
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.dashboard-container {
  padding: 24px;
  background-color: #f5f7fb;
  min-height: calc(100vh - 88px);
}

.dashboard-header {
  margin-bottom: 24px;

  h2 {
    font-size: 20px;
    font-weight: 700;
    color: #0f172a;
    margin: 0 0 4px;
  }

  p {
    font-size: 13px;
    color: #64748b;
    margin: 0;
  }
}

.panel-group {
  margin-bottom: 24px;

  .card-panel-col {
    margin-bottom: 20px;
  }

  .card-panel {
    height: 108px;
    cursor: default;
    font-size: 12px;
    position: relative;
    overflow: hidden;
    color: #374151;
    background: #fff;
    border-radius: 14px;
    border: 1px solid #eaecf0;
    box-shadow: 0 4px 16px rgba(15, 23, 42, 0.05);
    display: flex;
    align-items: center;
    padding: 0 20px;
    gap: 16px;
    transition: box-shadow 0.2s, transform 0.2s;

    &:hover {
      box-shadow: 0 8px 28px rgba(15, 23, 42, 0.10);
      transform: translateY(-2px);

      .card-panel-icon-wrapper {
        color: #fff;
      }

      .icon-people { background: #1890ff; }
      .icon-message { background: #36a3f7; }
      .icon-money { background: #f4516c; }
      .icon-shopping { background: #34bfa3; }
    }

    .icon-people { color: #1890ff; background: rgba(24, 144, 255, 0.10); }
    .icon-message { color: #36a3f7; background: rgba(54, 163, 247, 0.10); }
    .icon-money { color: #f4516c; background: rgba(244, 81, 108, 0.10); }
    .icon-shopping { color: #34bfa3; background: rgba(52, 191, 163, 0.10); }

    .card-panel-icon-wrapper {
      width: 60px;
      height: 60px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
      transition: all 0.25s ease;
    }

    .card-panel-icon {
      font-size: 32px;
    }

    .card-panel-description {
      flex: 1;

      .card-panel-text {
        font-size: 13px;
        color: #64748b;
        margin-bottom: 6px;
        font-weight: 500;
      }

      .card-panel-num {
        font-size: 26px;
        font-weight: 700;
        color: #0f172a;
        line-height: 1;
      }
    }
  }
}

.echarts-section {
  background: #fff;
  border-radius: 14px;
  border: 1px solid #eaecf0;
  box-shadow: 0 4px 16px rgba(15, 23, 42, 0.05);
  padding: 20px;
  margin-bottom: 20px;
}

@media (max-width: 550px) {
  .card-panel-description {
    display: none;
  }

  .card-panel-icon-wrapper {
    width: 100% !important;
    height: 100%;
    border-radius: 0;

    .svg-icon {
      display: block;
      margin: auto !important;
      float: none !important;
    }
  }
}
</style>
