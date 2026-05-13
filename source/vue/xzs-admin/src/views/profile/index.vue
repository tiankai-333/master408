<template>
  <div class="app-container">
    <el-row :gutter="20">
      <el-col :span="6">
        <UserCard :user="user"/>
      </el-col>
      <el-col :span="18">
        <Account />
      </el-col>
    </el-row>
    <Timeline />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import UserCard from './components/UserCard.vue'
import Account from './components/Account.vue'
import Timeline from './components/Timeline.vue'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()
const user = ref({})

onMounted(() => {
  user.value = userStore.userInfo
})
</script>