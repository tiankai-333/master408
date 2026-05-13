<template>
  <div class="dashboard-container">
    <el-row class="banner-row">
      <el-carousel :interval="5000" arrow="always" height="350px" indicator-position="bottom">
        <el-carousel-item v-for="(img, index) in carouselImages" :key="index">
          <img :src="img.src" class="carousel-img">
          <div class="carousel-overlay">
            <h2>{{ img.title }}</h2>
            <p>{{ img.desc }}</p>
          </div>
        </el-carousel-item>
      </el-carousel>
    </el-row>

    <div class="content-wrapper">
      <el-row class="section-row">
        <div class="section-header">
          <el-icon><Tickets /></el-icon>
          <h3>任务中心</h3>
        </div>
        <div class="task-content" v-loading="taskLoading">
          <el-collapse accordion v-if="taskList.length !== 0" class="task-collapse">
            <el-collapse-item :title="taskItem.title" :name="taskItem.id" :key="taskItem.id" v-for="taskItem in taskList">
              <table class="index-task-table">
                <tr v-for="paperItem in taskItem.paperItems" :key="paperItem.examPaperId">
                  <td class="index-task-table-paper">
                    <el-icon><Document /></el-icon>
                    {{ paperItem.examPaperName }}
                  </td>
                  <td width="70px">
                    <el-tag :type="statusTagFormatter(paperItem.status)" v-if="paperItem.status !== null" size="small">
                      {{ statusTextFormatter(paperItem.status) }}
                    </el-tag>
                  </td>
                  <td width="120px">
                    <router-link target="_blank" :to="{ path: '/do', query: { id: paperItem.examPaperId } }" v-if="paperItem.status === null">
                      <el-button type="primary" size="small"><el-icon><VideoPlay /></el-icon>开始答题</el-button>
                    </router-link>
                    <router-link target="_blank" :to="{ path: '/edit', query: { id: paperItem.examPaperAnswerId } }" v-else-if="paperItem.status === 1">
                      <el-button type="warning" size="small"><el-icon><Edit /></el-icon>批改试卷</el-button>
                    </router-link>
                    <router-link target="_blank" :to="{ path: '/read', query: { id: paperItem.examPaperAnswerId } }" v-else-if="paperItem.status === 2">
                      <el-button type="success" size="small"><el-icon><View /></el-icon>查看试卷</el-button>
                    </router-link>
                  </td>
                </tr>
              </table>
            </el-collapse-item>
          </el-collapse>
          <el-empty v-else description="暂无任务" />
        </div>
      </el-row>

      <el-row class="section-row">
        <div class="section-header">
          <el-icon><Collection /></el-icon>
          <h3>固定试卷</h3>
        </div>
        <div class="paper-grid" v-loading="loading">
          <el-col :span="6" v-for="(item, index) in fixedPaper" :key="index" class="paper-col">
            <el-card class="paper-card" shadow="hover">
              <div class="paper-image-wrapper">
                <img src="@/assets/exam-paper/show1.png" class="paper-image">
              </div>
              <div class="paper-info">
                <h4 class="paper-title">{{ item.name }}</h4>
                <div class="paper-action">
                  <router-link target="_blank" :to="{ path: '/do', query: { id: item.id } }">
                    <el-button type="primary" size="small"><el-icon><VideoPlay /></el-icon>开始做题</el-button>
                  </router-link>
                </div>
              </div>
            </el-card>
          </el-col>
        </div>
      </el-row>

      <el-row class="section-row">
        <div class="section-header time-header">
          <el-icon><Timer /></el-icon>
          <h3>时段试卷</h3>
        </div>
        <div class="paper-grid" v-loading="loading">
          <el-col :span="6" v-for="(item, index) in timeLimitPaper" :key="index" class="paper-col">
            <el-card class="paper-card time-card" shadow="hover">
              <div class="paper-image-wrapper">
                <img src="@/assets/exam-paper/show2.png" class="paper-image">
                <div class="time-badge">
                  <el-icon><Timer /></el-icon>
                </div>
              </div>
              <div class="paper-info">
                <h4 class="paper-title">{{ item.name }}</h4>
                <p class="paper-time">
                  <el-icon><Calendar /></el-icon>
                  {{ item.startTime }} - {{ item.endTime }}
                </p>
                <div class="paper-action">
                  <router-link target="_blank" :to="{ path: '/do', query: { id: item.id } }">
                    <el-button type="warning" size="small"><el-icon><VideoPlay /></el-icon>开始做题</el-button>
                  </router-link>
                </div>
              </div>
            </el-card>
          </el-col>
        </div>
      </el-row>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Tickets, Document, VideoPlay, Edit, View, Collection, Timer, Calendar } from '@element-plus/icons-vue'
import indexApi from '@/api/dashboard'
import { useEnumItemStore } from '@/store/modules/enumItem'

const enumItemStore = useEnumItemStore()

const fixedPaper = ref([])
const timeLimitPaper = ref([])
const loading = ref(false)
const taskLoading = ref(false)
const taskList = ref([])

const carouselImages = [
  { src: new URL('@/assets/carousel/1.png', import.meta.url).href, title: '智能考试系统', desc: 'AI驱动的智能测评平台' },
  { src: new URL('@/assets/carousel/2.png', import.meta.url).href, title: '个性化学习路径', desc: '定制专属学习方案' },
  { src: new URL('@/assets/carousel/3.png', import.meta.url).href, title: '数据分析报告', desc: '详细掌握学习进度' },
  { src: new URL('@/assets/carousel/4.png', import.meta.url).href, title: '限时挑战模式', desc: '提升应试能力' }
]

const statusTagFormatter = (status) => {
  return enumItemStore.enumFormat(enumItemStore.exam.examPaperAnswer.statusTag, status)
}

const statusTextFormatter = (status) => {
  return enumItemStore.enumFormat(enumItemStore.exam.examPaperAnswer.statusEnum, status)
}

onMounted(() => {
  loading.value = true
  indexApi.index().then(re => {
    fixedPaper.value = re.response.fixedPaper
    timeLimitPaper.value = re.response.timeLimitPaper
    loading.value = false
  })

  taskLoading.value = true
  indexApi.task().then(re => {
    taskList.value = re.response
    taskLoading.value = false
  })
})
</script>

<style lang="scss" scoped>
.dashboard-container {
  background-color: #f5f7fa;
  min-height: 100%;
}

.banner-row {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px 0;
}

.el-carousel {
  max-width: 1200px;
  margin: 0 auto;
}

.carousel-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 12px;
  transition: transform 0.6s ease;
}

.el-carousel-item:hover .carousel-img {
  transform: scale(1.08);
}

.carousel-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 40px;
  background: linear-gradient(to top, rgba(0, 0, 0, 0.7), transparent);
  border-radius: 0 0 12px 12px;

  h2 {
    font-size: 28px;
    font-weight: 700;
    color: #fff;
    margin: 0 0 10px;
    text-shadow: 0 2px 10px rgba(0, 0, 0, 0.5);
  }

  p {
    font-size: 16px;
    color: rgba(255, 255, 255, 0.9);
    margin: 0;
    text-shadow: 0 1px 5px rgba(0, 0, 0, 0.3);
  }
}

.content-wrapper {
  max-width: 1200px;
  margin: 0 auto;
  padding: 30px 20px;
}

.section-row {
  background: #fff;
  border-radius: 12px;
  padding: 25px;
  margin-bottom: 30px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);

  &:last-child {
    margin-bottom: 0;
  }
}

.section-header {
  display: flex;
  align-items: center;
  margin-bottom: 25px;
  padding-bottom: 15px;
  border-bottom: 2px solid #f0f0f0;

  .el-icon {
    font-size: 24px;
    color: #667eea;
    margin-right: 12px;
  }

  h3 {
    font-size: 22px;
    font-weight: 600;
    color: #1f2f3d;
    margin: 0;
  }
}

.time-header {
  .el-icon {
    color: #f59f5f;
  }
}

.task-collapse {
  border: none;

  :deep(.el-collapse-item__header) {
    font-size: 16px;
    font-weight: 500;
    color: #1f2f3d;
    border-bottom: 1px solid #e8e8e8;
    padding-left: 10px;
  }

  :deep(.el-collapse-item__wrap) {
    border-bottom: none;
  }

  :deep(.el-collapse-item__content) {
    padding: 15px 10px;
  }
}

.index-task-table {
  width: 100%;

  tr:hover {
    background-color: #f9fafb;
  }

  td {
    padding: 12px 10px;
    border-bottom: 1px solid #f0f0f0;
  }

  .index-task-table-paper {
    color: #34495e;
    font-size: 15px;

    .el-icon {
      color: #667eea;
      margin-right: 8px;
    }
  }
}

.paper-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
}

.paper-col {
  flex: 1 0 calc(25% - 20px);
  max-width: calc(25% - 20px);
  min-width: 250px;
}

.paper-card {
  border: none;
  border-radius: 12px;
  overflow: hidden;
  transition: all 0.3s;

  &:hover {
    transform: translateY(-8px);
    box-shadow: 0 12px 24px rgba(102, 126, 234, 0.15);
  }
}

.paper-image-wrapper {
  position: relative;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.paper-image {
  width: 100%;
  height: 120px;
  object-fit: contain;
  filter: brightness(0) invert(1);
}

.time-badge {
  position: absolute;
  top: 15px;
  right: 15px;
  background: rgba(255, 255, 255, 0.9);
  border-radius: 50%;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;

  .el-icon {
    color: #f59f5f;
    font-size: 18px;
  }
}

.paper-info {
  padding: 20px;
  text-align: center;
}

.paper-title {
  font-size: 16px;
  font-weight: 600;
  color: #1f2f3d;
  margin: 0 0 15px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.paper-time {
  font-size: 13px;
  color: #909399;
  margin: 0 0 15px;

  .el-icon {
    margin-right: 5px;
  }
}

.paper-action {
  .el-button {
    width: 100%;
    border-radius: 20px;
  }
}

.el-empty {
  padding: 60px 0;
}

@media screen and (max-width: 1200px) {
  .paper-col {
    flex: 1 0 calc(33.333% - 20px);
    max-width: calc(33.333% - 20px);
  }
}

@media screen and (max-width: 768px) {
  .paper-col {
    flex: 1 0 calc(50% - 20px);
    max-width: calc(50% - 20px);
  }

  .section-header h3 {
    font-size: 18px;
  }
}

@media screen and (max-width: 480px) {
  .paper-col {
    flex: 1 0 100%;
    max-width: 100%;
  }
}
</style>
