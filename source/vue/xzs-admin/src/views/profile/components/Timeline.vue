<template>
  <el-card title="最近活动" style="margin-top: 20px;">
    <el-timeline>
      <el-timeline-item
        v-for="(activity, index) in activities"
        :key="index"
        :timestamp="activity.time">
        <el-card>
          <h4>{{ activity.title }}</h4>
          <p>{{ activity.description }}</p>
        </el-card>
      </el-timeline-item>
    </el-timeline>
  </el-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import logApi from '@/api/log'

const activities = ref([])

onMounted(() => {
  logApi.recent().then(data => {
    activities.value = data.response.map(item => ({
      title: item.operation,
      description: `请求路径: ${item.requestUri}`,
      time: item.createTime
    }))
  })
})
</script>