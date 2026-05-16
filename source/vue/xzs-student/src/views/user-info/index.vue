<template>
  <div class="user-info-container">
    <div class="user-info-header">
      <div class="header-icon"><el-icon><User /></el-icon></div>
      <h2>个人中心</h2>
      <p>管理您的个人信息和账户设置</p>
    </div>
    <div class="user-info-content">
      <el-row :gutter="30">
        <el-col :span="8">
          <el-card class="profile-card" shadow="hover">
            <template #header>
              <div class="card-header"><el-icon><Postcard /></el-icon><span>个人信息</span></div>
            </template>
            <div class="profile-content">
              <div class="avatar-wrapper">
                <el-upload action="/api/student/upload/image" accept=".jpg,.png" :show-file-list="false" :on-success="uploadSuccess">
                  <el-avatar class="el-dropdown-avatar" :size="120" :src="form.imagePath === null ? avatarDefault : form.imagePath"></el-avatar>
                  <div class="avatar-overlay"><el-icon><Camera /></el-icon></div>
                </el-upload>
              </div>
              <div class="user-name">{{ form.userName }}</div>
              <div class="user-stats">
                <div class="stat-item"><el-icon><Medal /></el-icon><span class="stat-label">姓名</span><span class="stat-value">{{ form.realName || '未填写' }}</span></div>
                <div class="stat-item"><el-icon><Calendar /></el-icon><span class="stat-label">注册时间</span><span class="stat-value">{{ form.createTime }}</span></div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="16">
          <el-card class="detail-card" shadow="hover">
            <el-tabs model-value="event" type="card" class="custom-tabs">
              <el-tab-pane label="用户动态" name="event">
                <div class="timeline-wrapper">
                  <el-timeline>
                    <el-timeline-item :timestamp="item.createTime" placement="top" :key="item.id" v-for="item in event">
                      <el-card class="timeline-card" shadow="hover"><p><el-icon><Document /></el-icon> {{ item.content }}</p></el-card>
                    </el-timeline-item>
                  </el-timeline>
                </div>
              </el-tab-pane>
              <el-tab-pane label="个人资料修改" name="update">
                <el-form :model="form" ref="formRef" label-width="120px" v-loading="formLoading" :rules="rules" class="update-form">
                  <el-form-item label="真实姓名：" prop="realName" required>
                    <el-input v-model="form.realName" placeholder="请输入真实姓名" />
                  </el-form-item>
                  <el-form-item label="年龄：">
                    <el-input v-model="form.age" placeholder="请输入年龄" />
                  </el-form-item>
                  <el-form-item label="性别：">
                    <el-select v-model="form.sex" placeholder="请选择性别" clearable class="full-width">
                      <el-option v-for="item in sexEnum" :key="item.key" :value="item.key" :label="item.value"></el-option>
                    </el-select>
                  </el-form-item>
                  <el-form-item label="出生日期：">
                    <el-date-picker v-model="form.birthDay" value-format="YYYY-MM-DD" type="date" placeholder="选择日期" class="full-width" />
                  </el-form-item>
                  <el-form-item label="手机：">
                    <el-input v-model="form.phone" placeholder="请输入手机号" />
                  </el-form-item>
                  <el-form-item>
                    <el-button type="primary" @click="submitForm" class="submit-btn"><el-icon><Check /></el-icon> 更新信息</el-button>
                  </el-form-item>
                </el-form>
              </el-tab-pane>
            </el-tabs>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { User, Postcard, Camera, Medal, Calendar, Document, Check } from '@element-plus/icons-vue'
import userApi from '@/api/user'
import { useEnumItemStore } from '@/store/modules/enumItem'
import avatarDefault from '@/assets/avatar.png'

const enumItemStore = useEnumItemStore()
const sexEnum = enumItemStore.user.sexEnum

const formRef = ref(null)
const event = ref([])
const formLoading = ref(false)
const form = reactive({
  userName: '', realName: '', age: '', sex: '', birthDay: null,
  phone: null, userLevel: null, createTime: null, imagePath: null
})

const rules = {
  realName: [{ required: true, message: '请输入真实姓名', trigger: 'blur' }]
}

const uploadSuccess = (re) => {
  if (re.code === 1) {
    window.location.reload()
  } else {
    ElMessage.error(re.message)
  }
}

const submitForm = () => {
  formRef.value.validate((valid) => {
    if (valid) {
      formLoading.value = true
      userApi.update(form).then(data => {
        if (data.code === 1) {
          ElMessage.success(data.message)
        } else {
          ElMessage.error(data.message)
        }
        formLoading.value = false
      }).catch(() => {
        formLoading.value = false
      })
    }
  })
}

onMounted(() => {
  userApi.getUserEvent().then(re => { event.value = re.response })
  userApi.getCurrentUser().then(re => { Object.assign(form, re.response) })
})
</script>

<style lang="scss" scoped>
.user-info-container { background-color: #f5f7fa; min-height: calc(100vh - 70px); padding: 30px; }
.user-info-header {
  text-align: center; margin-bottom: 40px; padding: 40px 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 16px; color: #fff;
  .header-icon { width: 80px; height: 80px; margin: 0 auto 20px; background: rgba(255,255,255,0.2); border-radius: 50%; display: flex; align-items: center; justify-content: center;
    .el-icon { font-size: 36px; color: #fff; }
  }
  h2 { font-size: 32px; font-weight: 700; margin: 0 0 10px; }
  p { font-size: 16px; opacity: 0.9; margin: 0; }
}
.user-info-content { max-width: 1400px; margin: 0 auto; }
.profile-card, .detail-card { border: none; border-radius: 16px; overflow: hidden; height: 100%;
  .card-header { display: flex; align-items: center; font-size: 18px; font-weight: 600; color: #1f2f3d;
    .el-icon { margin-right: 10px; color: #667eea; font-size: 20px; }
  }
}
.profile-card {
  .profile-content { padding: 30px 20px; }
  .avatar-wrapper { position: relative; width: 120px; height: 120px; margin: 0 auto 20px; border-radius: 50%; overflow: hidden;
    .el-avatar { display: block; width: 100%; height: 100%; }
    .avatar-overlay { position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; opacity: 0; transition: opacity 0.3s; cursor: pointer;
      .el-icon { font-size: 30px; color: #fff; }
    }
    &:hover .avatar-overlay { opacity: 1; }
  }
  .user-name { text-align: center; font-size: 24px; font-weight: 700; color: #1f2f3d; margin-bottom: 30px; }
  .user-stats { background: #f8f9fa; border-radius: 12px; padding: 20px;
    .stat-item { display: flex; align-items: center; padding: 12px 0; border-bottom: 1px solid #e8e8e8;
      &:last-child { border-bottom: none; }
      .el-icon { font-size: 18px; color: #667eea; margin-right: 12px; }
      .stat-label { flex: 1; color: #606266; font-size: 14px; }
      .stat-value { color: #1f2f3d; font-weight: 600; font-size: 14px; }
    }
  }
}
.detail-card {
  .custom-tabs {
    :deep(.el-tabs__item) { font-size: 16px; padding: 0 30px; height: 50px; line-height: 50px;
      &.is-active { color: #667eea; font-weight: 600; }
      &:hover { color: #667eea; }
    }
  }
  .timeline-wrapper { max-height: 500px; overflow-y: auto; padding: 10px;
    .timeline-card { border: none; border-radius: 10px; box-shadow: 0 2px 12px rgba(0,0,0,0.05);
      p { margin: 0; color: #1f2f3d; line-height: 1.6;
        .el-icon { margin-right: 8px; color: #667eea; }
      }
    }
  }
  .update-form { padding: 20px;
    .full-width { width: 100%; }
    .submit-btn { width: 100%; height: 48px; border-radius: 8px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none; font-size: 16px; font-weight: 600; margin-top: 20px;
      .el-icon { margin-right: 8px; }
      &:hover { opacity: 0.9; transform: translateY(-2px); }
    }
  }
}
@media screen and (max-width: 992px) {
  .el-col-8, .el-col-16 { width: 100%; }
  .el-col-16 { margin-top: 20px; }
}
</style>
