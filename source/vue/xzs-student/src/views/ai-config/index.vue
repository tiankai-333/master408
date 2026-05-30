<template>
  <div class="ai-config-container">
    <div class="page-header">
      <div class="header-icon"><el-icon><Key /></el-icon></div>
      <h2>密钥管理</h2>
      <p>查看公用 AI 密钥，或添加您自己的私用密钥</p>
    </div>

    <div class="config-content">
      <!-- 公用密钥 -->
      <el-card class="section-card" shadow="hover">
        <template #header>
          <div class="card-header">
            <span><el-icon><Lock /></el-icon> 公用密钥</span>
            <el-tag type="info" size="small">只读</el-tag>
          </div>
        </template>
        <el-table :data="publicProviders" stripe style="width: 100%">
          <el-table-column prop="providerName" label="供应商" width="120" />
          <el-table-column prop="providerCode" label="代码" width="100" />
          <el-table-column prop="apiBaseUrl" label="Base URL" min-width="200" show-overflow-tooltip />
          <el-table-column prop="chatModel" label="对话模型" width="150" show-overflow-tooltip />
          <el-table-column label="视觉模型" width="140">
            <template #default="{ row }">
              {{ row.visionModel || visionFallback(row.providerCode) || '-' }}
            </template>
          </el-table-column>
          <el-table-column label="Embedding" width="160">
            <template #default="{ row }">
              {{ row.embeddingModel || embeddingFallback(row.providerCode) || '-' }}
            </template>
          </el-table-column>
          <el-table-column label="密钥" width="120" align="center">
            <template #default="{ row }">
              <el-tag v-if="row.apiKeyMask" type="success" size="small">{{ row.apiKeyMask }}</el-tag>
              <el-tag v-else type="info" size="small">未设置</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="状态" width="80" align="center">
            <template #default="{ row }">
              <el-tag :type="row.enabled ? 'success' : 'info'" size="small">{{ row.enabled ? '启用' : '停用' }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="priority" label="优先级" width="80" align="center" />
          <el-table-column label="测试" width="160" align="center">
            <template #default="{ row }">
              <el-button size="small" type="primary" @click="testPublic(row)" :loading="row._testing">测试</el-button>
              <el-tooltip v-if="row.lastTestMessage" :content="row.lastTestMessage" placement="top">
                <el-tag :type="row.lastTestSuccess ? 'success' : 'danger'" size="small">
                  {{ row.lastTestSuccess ? '通过' : '失败' }}
                </el-tag>
              </el-tooltip>
            </template>
          </el-table-column>
        </el-table>
      </el-card>

      <!-- 我的密钥 -->
      <el-card class="section-card" shadow="hover">
        <template #header>
          <div class="card-header">
            <span><el-icon><User /></el-icon> 我的密钥</span>
            <el-button type="primary" size="small" @click="openCreate">
              <el-icon><Plus /></el-icon> 新增密钥
            </el-button>
          </div>
        </template>
        <el-table :data="userKeys" stripe style="width: 100%">
          <el-table-column prop="providerName" label="供应商" width="120" />
          <el-table-column prop="providerCode" label="代码" width="100" />
          <el-table-column prop="apiBaseUrl" label="Base URL" min-width="200" show-overflow-tooltip />
          <el-table-column prop="chatModel" label="对话模型" width="150" show-overflow-tooltip />
          <el-table-column label="视觉模型" width="140">
            <template #default="{ row }">
              {{ row.visionModel || visionFallback(row.providerCode) || '-' }}
            </template>
          </el-table-column>
          <el-table-column label="Embedding" width="160">
            <template #default="{ row }">
              {{ row.embeddingModel || embeddingFallback(row.providerCode) || '-' }}
            </template>
          </el-table-column>
          <el-table-column label="密钥" width="120" align="center">
            <template #default="{ row }">
              <el-tag v-if="row.apiKeyMask" type="success" size="small">{{ row.apiKeyMask }}</el-tag>
              <el-tag v-else type="info" size="small">未设置</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="启用" width="90" align="center">
            <template #default="{ row }">
              <el-switch v-model="row.enabled" :disabled="!row.apiKeyMask" @change="toggleEnabled(row)" />
            </template>
          </el-table-column>
          <el-table-column prop="priority" label="优先级" width="80" align="center" />
          <el-table-column label="测试" width="120" align="center">
            <template #default="{ row }">
              <el-tooltip v-if="row.lastTestMessage" :content="row.lastTestMessage" placement="top">
                <el-tag :type="row.lastTestSuccess ? 'success' : 'danger'" size="small">
                  {{ row.lastTestSuccess ? '通过' : '失败' }}
                </el-tag>
              </el-tooltip>
              <span v-else class="text-muted">-</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="200" fixed="right">
            <template #default="{ row }">
              <el-button size="small" @click="openEdit(row)">编辑</el-button>
              <el-button size="small" type="primary" @click="testKey(row)">测试</el-button>
              <el-button size="small" type="danger" @click="deleteKey(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
        <el-empty v-if="userKeys.length === 0" description="暂无私用密钥，点击上方按钮添加" />
      </el-card>

      <!-- 用量分析 -->
      <el-card class="section-card" shadow="hover">
        <template #header>
          <div class="card-header">
            <span><el-icon><DataAnalysis /></el-icon> 我的用量</span>
            <el-select v-model="usageDays" size="small" style="width: 100px" @change="loadUsage">
              <el-option :value="7" label="近 7 天" />
              <el-option :value="30" label="近 30 天" />
              <el-option :value="90" label="近 90 天" />
            </el-select>
          </div>
        </template>

        <h4 class="table-section-title">公用密钥</h4>
        <div class="metric-row">
          <div class="metric">
            <div class="metric-label">请求数</div>
            <div class="metric-value">{{ publicSummary.requestCount || 0 }}</div>
          </div>
          <div class="metric">
            <div class="metric-label">Token</div>
            <div class="metric-value">{{ publicSummary.tokensUsed || 0 }}</div>
          </div>
          <div class="metric">
            <div class="metric-label">费用</div>
            <div class="metric-value">{{ formatCost(publicSummary.cost) }}</div>
          </div>
          <div class="metric">
            <div class="metric-label">成功率</div>
            <div class="metric-value">{{ calcSuccessRate(publicSummary) }}</div>
          </div>
        </div>
        <div class="scroll-table-wrap">
          <el-table :data="publicLogs" stripe size="small">
            <el-table-column prop="createTime" label="时间" width="170" />
            <el-table-column label="供应商" width="100">
              <template #default="{ row }">{{ providerDisplayName(row.provider) }}</template>
            </el-table-column>
            <el-table-column prop="model" label="模型" width="150" show-overflow-tooltip />
            <el-table-column prop="taskType" label="类型" width="100">
              <template #default="{ row }">
                <el-tag :type="row.taskType === 'embedding' ? 'warning' : row.taskType === 'vision' ? 'success' : 'primary'" size="small">{{ row.taskType === 'embedding' ? 'Embedding' : row.taskType === 'vision' ? '视觉' : '对话' }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="Token" width="200">
              <template #default="{ row }">
                {{ row.tokensUsed || 0 }} <span style="color:#909399;font-size:12px">({{ row.cacheHitTokens || 0 }}/{{ Math.max(0, (row.inputTokens || 0) - (row.cacheHitTokens || 0)) }}/{{ row.outputTokens || 0 }})</span>
              </template>
            </el-table-column>
            <el-table-column label="费用" width="100">
              <template #default="{ row }">{{ formatCost(row.cost) }}</template>
            </el-table-column>
            <el-table-column prop="durationMs" label="耗时(ms)" width="100" />
            <el-table-column label="状态" width="80" align="center">
              <template #default="{ row }">
                <el-tag :type="row.success ? 'success' : 'danger'" size="small">{{ row.success ? '成功' : '失败' }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="question" label="问题" min-width="120" show-overflow-tooltip />
          </el-table>
        </div>
        <el-empty v-if="!publicLogs.length" description="暂无公用密钥使用记录" :image-size="60" />

        <h4 class="table-section-title">私用密钥</h4>
        <div class="metric-row">
          <div class="metric">
            <div class="metric-label">请求数</div>
            <div class="metric-value">{{ privateSummary.requestCount || 0 }}</div>
          </div>
          <div class="metric">
            <div class="metric-label">Token</div>
            <div class="metric-value">{{ privateSummary.tokensUsed || 0 }}</div>
          </div>
          <div class="metric">
            <div class="metric-label">费用</div>
            <div class="metric-value">{{ formatCost(privateSummary.cost) }}</div>
          </div>
          <div class="metric">
            <div class="metric-label">成功率</div>
            <div class="metric-value">{{ calcSuccessRate(privateSummary) }}</div>
          </div>
        </div>
        <div class="scroll-table-wrap">
          <el-table :data="privateLogs" stripe size="small">
            <el-table-column prop="createTime" label="时间" width="170" />
            <el-table-column label="供应商" width="100">
              <template #default="{ row }">{{ providerDisplayName(row.provider) }}</template>
            </el-table-column>
            <el-table-column prop="model" label="模型" width="150" show-overflow-tooltip />
            <el-table-column prop="taskType" label="类型" width="100">
              <template #default="{ row }">
                <el-tag :type="row.taskType === 'embedding' ? 'warning' : row.taskType === 'vision' ? 'success' : 'primary'" size="small">{{ row.taskType === 'embedding' ? 'Embedding' : row.taskType === 'vision' ? '视觉' : '对话' }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="Token" width="200">
              <template #default="{ row }">
                {{ row.tokensUsed || 0 }} <span style="color:#909399;font-size:12px">({{ row.cacheHitTokens || 0 }}/{{ Math.max(0, (row.inputTokens || 0) - (row.cacheHitTokens || 0)) }}/{{ row.outputTokens || 0 }})</span>
              </template>
            </el-table-column>
            <el-table-column label="费用" width="100">
              <template #default="{ row }">{{ formatCost(row.cost) }}</template>
            </el-table-column>
            <el-table-column prop="durationMs" label="耗时(ms)" width="100" />
            <el-table-column label="状态" width="80" align="center">
              <template #default="{ row }">
                <el-tag :type="row.success ? 'success' : 'danger'" size="small">{{ row.success ? '成功' : '失败' }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="question" label="问题" min-width="120" show-overflow-tooltip />
          </el-table>
        </div>
        <el-empty v-if="!privateLogs.length" description="暂无私用密钥使用记录" :image-size="60" />

        <h4 class="table-section-title">按模型汇总</h4>
        <el-table :data="usage.byProvider || []" stripe size="small">
          <el-table-column label="供应商" width="140">
            <template #default="{ row }">{{ providerDisplayName(row.provider) }}</template>
          </el-table-column>
          <el-table-column prop="model" label="模型" />
          <el-table-column prop="requestCount" label="请求数" width="100" />
          <el-table-column prop="tokensUsed" label="Token" width="120" />
          <el-table-column label="费用" width="120">
            <template #default="{ row }">{{ formatCost(row.cost) }}</template>
          </el-table-column>
          <el-table-column prop="successCount" label="成功" width="100" />
        </el-table>
        <el-empty v-if="!(usage.byProvider && usage.byProvider.length)" description="暂无汇总数据" :image-size="60" />
      </el-card>
    </div>

    <!-- 新增/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="isEditing ? '编辑密钥' : '新增密钥'" width="680px" destroy-on-close>
      <el-form :model="form" label-width="120px">
        <el-form-item label="供应商代码">
          <el-input v-model="form.providerCode" :disabled="isEditing" placeholder="deepseek / zhipu / openai / custom" />
        </el-form-item>
        <el-form-item label="供应商名称">
          <el-input v-model="form.providerName" placeholder="如：DeepSeek" />
        </el-form-item>
        <el-form-item label="Base URL">
          <el-input v-model="form.apiBaseUrl" placeholder="留空使用默认地址" />
        </el-form-item>
        <el-form-item label="对话模型">
          <el-input v-model="form.chatModel" placeholder="留空使用默认模型" />
        </el-form-item>
        <el-form-item label="Embedding 模型">
          <el-input v-model="form.embeddingModel" autocomplete="off" placeholder="智谱默认 embedding-2，OpenAI 默认 text-embedding-3-small" />
        </el-form-item>
        <el-form-item label="视觉模型">
          <el-input v-model="form.visionModel" autocomplete="off" placeholder="智谱默认 glm-4v-flash，OpenAI 默认 gpt-4o" />
        </el-form-item>
        <el-form-item label="API Key">
          <el-input v-model="form.apiKey" type="password" show-password autocomplete="new-password" placeholder="留空表示不修改已有密钥" />
        </el-form-item>
        <el-form-item label="优先级">
          <el-input-number v-model="form.priority" :min="1" :max="999" />
        </el-form-item>
        <el-form-item label="启用">
          <el-switch v-model="form.enabled" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveKey">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Key, Lock, User, Plus, DataAnalysis } from '@element-plus/icons-vue'
import aiConfigApi from '@/api/aiConfig'

const publicProviders = ref([])
const userKeys = ref([])
const dialogVisible = ref(false)
const usageDays = ref(30)
const usage = ref({})

const form = reactive({
  id: null,
  providerCode: '',
  providerName: '',
  apiBaseUrl: '',
  chatModel: '',
  embeddingModel: '',
  visionModel: '',
  apiKey: '',
  priority: 100,
  enabled: false
})

const isEditing = computed(() => form.id !== null)
const summary = computed(() => usage.value.summary || {})
const publicSummary = computed(() => {
  const list = usage.value.summaryByKeySource || []
  const row = list.find(r => r.keySource !== 'private')
  return row || {}
})
const privateSummary = computed(() => {
  const list = usage.value.summaryByKeySource || []
  const row = list.find(r => r.keySource === 'private')
  return row || {}
})
const calcSuccessRate = (s) => {
  if (!s || !s.requestCount) return '0%'
  return (s.successCount / s.requestCount * 100).toFixed(2) + '%'
}
const publicLogs = computed(() => (usage.value.recentLogs || []).filter(r => r.keySource !== 'private'))
const privateLogs = computed(() => (usage.value.recentLogs || []).filter(r => r.keySource === 'private'))

const formatCost = (value) => {
  const n = Number(value)
  return isNaN(n) ? '0' : n.toFixed(4)
}

const resetForm = () => {
  form.id = null
  form.providerCode = ''
  form.providerName = ''
  form.apiBaseUrl = ''
  form.chatModel = ''
  form.embeddingModel = ''
  form.visionModel = ''
  form.apiKey = ''
  form.priority = 100
  form.enabled = false
}

const providerDisplayName = (code) => {
  const p = publicProviders.value.find(p => p.providerCode === code)
  return p ? p.providerName : code
}

const embeddingFallback = (code) => {
  if (code === 'zhipu') return 'embedding-2'
  if (code === 'openai') return 'text-embedding-3-small'
  return ''
}

const visionFallback = (code) => {
  if (code === 'zhipu') return 'glm-4v-flash'
  if (code === 'openai') return 'gpt-4o'
  return ''
}

const loadPublicProviders = () => {
  aiConfigApi.publicProviders().then(re => { publicProviders.value = re.response })
}

const testPublic = (row) => {
  row._testing = true
  aiConfigApi.testPublicProvider(row.id).then(re => {
    const result = re.response
    if (result.success) {
      ElMessage.success(result.message)
    } else {
      ElMessage.error(result.message)
    }
    loadPublicProviders()
  }).finally(() => { row._testing = false })
}

const loadUserKeys = () => {
  aiConfigApi.userKeys().then(re => { userKeys.value = re.response })
}

const loadUsage = () => {
  aiConfigApi.usage({ days: usageDays.value }).then(re => { usage.value = re.response || {} })
}

const openCreate = () => {
  resetForm()
  dialogVisible.value = true
}

const openEdit = (row) => {
  form.id = row.id
  form.providerCode = row.providerCode
  form.providerName = row.providerName
  form.apiBaseUrl = row.apiBaseUrl
  form.chatModel = row.chatModel
  form.embeddingModel = row.embeddingModel
  form.visionModel = row.visionModel || ''
  form.apiKey = ''
  form.priority = row.priority
  form.enabled = row.enabled
  dialogVisible.value = true
}

const saveKey = () => {
  aiConfigApi.saveUserKey({ ...form }).then(re => {
    if (re.code === 1) {
      ElMessage.success('保存成功')
      dialogVisible.value = false
      loadUserKeys()
    }
  })
}

const toggleEnabled = (row) => {
  aiConfigApi.saveUserKey({
    id: row.id,
    providerCode: row.providerCode,
    providerName: row.providerName,
    apiBaseUrl: row.apiBaseUrl,
    chatModel: row.chatModel,
    embeddingModel: row.embeddingModel,
    apiKey: '',
    priority: row.priority,
    enabled: row.enabled
  }).then(() => {
    ElMessage.success('状态已更新')
  }).catch(() => {
    row.enabled = !row.enabled
  })
}

const testKey = (row) => {
  aiConfigApi.testUserKey(row.id).then(re => {
    const result = re.response
    if (result.success) {
      ElMessage.success(result.message)
    } else {
      ElMessage.error(result.message)
    }
    loadUserKeys()
  })
}

const deleteKey = (row) => {
  ElMessageBox.confirm('确定删除该密钥？', '提示', { type: 'warning' }).then(() => {
    aiConfigApi.deleteUserKey(row.id).then(re => {
      if (re.code === 1) {
        ElMessage.success('已删除')
        loadUserKeys()
      }
    })
  }).catch(() => {})
}

onMounted(() => {
  loadPublicProviders()
  loadUserKeys()
  loadUsage()
})
</script>

<style lang="scss" scoped>
.ai-config-container {
  background-color: #f5f7fa;
  min-height: calc(100vh - 70px);
  padding: 30px;
}

.page-header {
  text-align: center;
  margin-bottom: 30px;
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

    .el-icon {
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

.config-content {
  max-width: 1400px;
  margin: 0 auto;
}

.section-card {
  border: none;
  border-radius: 16px;
  margin-bottom: 24px;

  .card-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: 18px;
    font-weight: 600;
    color: #1f2f3d;

    > span {
      display: flex;
      align-items: center;
      gap: 8px;

      .el-icon {
        color: #667eea;
        font-size: 20px;
      }
    }
  }
}

.text-muted {
  color: #c0c4cc;
}

.table-section-title {
  font-size: 15px;
  font-weight: 600;
  color: #303133;
  margin: 16px 0 8px;
}

.scroll-table-wrap {
  max-height: 300px;
  overflow-y: auto;
}

.metric-row {
  display: flex;
  gap: 16px;
  margin-bottom: 20px;
}

.metric {
  flex: 1;
  border: 1px solid #ebeef5;
  border-radius: 6px;
  padding: 14px 16px;
  background: #fff;
  text-align: center;

  .metric-label {
    font-size: 13px;
    color: #909399;
  }

  .metric-value {
    font-size: 24px;
    font-weight: 700;
    color: #1f2f3d;
    margin-top: 8px;
  }
}
</style>
