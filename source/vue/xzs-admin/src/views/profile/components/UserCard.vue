<template>
  <el-card class="user-card">
    <div class="user-avatar">
      <img :src="user.avatar || '/avatar.png'" alt="头像"/>
    </div>
    <h2>{{ user.userName }}</h2>
    <p>管理员</p>
    <div class="user-info">
      <div class="info-item">
        <span>邮箱：</span>{{ user.email }}
      </div>
      <div class="info-item">
        <span>电话：</span>{{ user.phone }}
      </div>
      <div class="info-item">
        <span>创建时间：</span>{{ user.createTime }}
      </div>
    </div>
  </el-card>
</template>

<script setup>
defineProps({
  user: {
    type: Object,
    default: () => ({})
  }
})
</script>

<style scoped>
.user-card {
  text-align: center;
  padding: 20px;
}
.user-avatar {
  width: 120px;
  height: 120px;
  margin: 0 auto 20px;
  border-radius: 50%;
  overflow: hidden;
  border: 3px solid #eee;
  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
}
.user-info {
  margin-top: 20px;
  text-align: left;
}
.info-item {
  margin-bottom: 10px;
  color: #666;
}
</style>