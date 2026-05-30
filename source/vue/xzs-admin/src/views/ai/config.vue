<template>
  <div class="app-container ai-config-page">
    <el-row :gutter="16">
      <el-col :span="24">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span>AI 密钥配置</span>
              <el-button type="primary" @click="openCreate">新增供应商</el-button>
            </div>
          </template>
          <el-table v-loading="loading" :data="providers" border fit highlight-current-row>
            <el-table-column prop="providerName" label="供应商" width="130"/>
            <el-table-column prop="providerCode" label="代码" width="110"/>
            <el-table-column prop="apiBaseUrl" label="Base URL" min-width="220"/>
            <el-table-column prop="chatModel" label="对话模型" width="150"/>
            <el-table-column prop="visionModel" label="视觉模型" width="150">
              <template #default="{ row }">
                <span>{{ row.visionModel || visionFallback(row.providerCode) || '-' }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="embeddingModel" label="Embedding 模型" width="170">
              <template #default="{ row }">
                <span>{{ row.embeddingModel || embeddingFallback(row.providerCode) || '-' }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="apiKeyMask" label="密钥" width="130">
              <template #default="{ row }">
                <el-tag v-if="row.apiKeyMask" type="success">{{ row.apiKeyMask }}</el-tag>
                <el-tag v-else type="info">未设置</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="enabled" label="启用" width="90">
              <template #default="{ row }">
                <el-switch
                  v-model="row.enabled"
                  :disabled="!row.apiKeyMask"
                  @change="toggleEnabled(row)"
                />
              </template>
            </el-table-column>
            <el-table-column label="测试" width="180">
              <template #default="{ row }">
                <el-tooltip v-if="row.lastTestMessage" :content="row.lastTestMessage" placement="top" :show-after="300">
                  <el-tag v-if="row.lastTestSuccess === true" type="success">成功</el-tag>
                  <el-tag v-else-if="row.lastTestSuccess === false" type="danger">失败</el-tag>
                  <el-tag v-else type="info">未测试</el-tag>
                </el-tooltip>
                <template v-else>
                  <el-tag v-if="row.lastTestSuccess === true" type="success">成功</el-tag>
                  <el-tag v-else-if="row.lastTestSuccess === false" type="danger">失败</el-tag>
                  <el-tag v-else type="info">未测试</el-tag>
                </template>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="230" fixed="right">
              <template #default="{ row }">
                <el-button size="small" @click="openEdit(row)">编辑</el-button>
                <el-button size="small" type="primary" @click="test(row)">测试</el-button>
                <el-button size="small" type="danger" @click="deleteProvider(row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="16" class="usage-row">
      <el-col :span="24">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span>用量分析</span>
              <div>
                <el-select v-model="usageQuery.days" style="width: 120px" @change="loadUsage">
                  <el-option :value="7" label="近 7 天"/>
                  <el-option :value="30" label="近 30 天"/>
                  <el-option :value="90" label="近 90 天"/>
                </el-select>
              </div>
            </div>
          </template>
          <el-row :gutter="16" class="metric-row">
            <el-col :span="6">
              <div class="metric">
                <div class="metric-label">请求数</div>
                <div class="metric-value">{{ summary.requestCount || 0 }}</div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="metric">
                <div class="metric-label">Token</div>
                <div class="metric-value">{{ summary.tokensUsed || 0 }}</div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="metric">
                <div class="metric-label">费用</div>
                <div class="metric-value">{{ formatCost(summary.cost) }}</div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="metric">
                <div class="metric-label">成功率</div>
                <div class="metric-value">{{ successRate }}</div>
              </div>
            </el-col>
          </el-row>
          <el-table :data="usage.recentLogs || []" border fit max-height="400">
            <el-table-column prop="createTime" label="时间" width="170"/>
            <el-table-column prop="provider" label="供应商" width="100">
              <template #default="{ row }">{{ providerName(row.provider) }}</template>
            </el-table-column>
            <el-table-column prop="model" label="模型" width="150"/>
            <el-table-column prop="taskType" label="类型" width="100">
              <template #default="{ row }">
                <el-tag size="small" :type="row.taskType === 'embedding' ? 'warning' : row.taskType === 'vision' ? 'success' : 'primary'">
                  {{ row.taskType === 'embedding' ? 'Embedding' : row.taskType === 'vision' ? '视觉' : '对话' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="Token (命中/输入/输出)" width="200">
              <template #default="{ row }">
                {{ row.tokensUsed || 0 }}
                <span style="color:#909399;font-size:12px">
                  ({{ row.cacheHitTokens || 0 }}/{{ Math.max(0, (row.inputTokens || 0) - (row.cacheHitTokens || 0)) }}/{{ row.outputTokens || 0 }})
                </span>
              </template>
            </el-table-column>
            <el-table-column prop="cost" label="费用" width="100">
              <template #default="{ row }">{{ formatCost(row.cost) }}</template>
            </el-table-column>
            <el-table-column prop="durationMs" label="耗时(ms)" width="100"/>
            <el-table-column label="状态" width="80">
              <template #default="{ row }">
                <el-tag size="small" :type="row.success ? 'success' : 'danger'">{{ row.success ? '成功' : '失败' }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="question" label="问题" min-width="120" show-overflow-tooltip/>
          </el-table>
          <el-table :data="usage.byProvider || []" border fit>
            <el-table-column prop="provider" label="供应商" width="140">
              <template #default="{ row }">{{ providerName(row.provider) }}</template>
            </el-table-column>
            <el-table-column prop="model" label="模型"/>
            <el-table-column prop="requestCount" label="请求数" width="110"/>
            <el-table-column prop="tokensUsed" label="Token" width="120"/>
            <el-table-column prop="cost" label="费用" width="120">
              <template #default="{ row }">{{ formatCost(row.cost) }}</template>
            </el-table-column>
            <el-table-column prop="successCount" label="成功" width="100"/>
          </el-table>
        </el-card>
      </el-col>
    </el-row>

    <el-dialog v-model="dialog.visible" title="AI 供应商配置" width="680px">
      <el-form :model="form" label-width="130px">
        <el-form-item label="供应商代码">
          <el-input v-model="form.providerCode" placeholder="deepseek / zhipu / openai / custom" :disabled="isEditing"/>
        </el-form-item>
        <el-form-item label="供应商名称">
          <el-input v-model="form.providerName"/>
        </el-form-item>
        <el-form-item label="Base URL">
          <el-input v-model="form.apiBaseUrl"/>
        </el-form-item>
        <el-form-item label="对话模型">
          <el-input v-model="form.chatModel"/>
        </el-form-item>
        <el-form-item label="Embedding 模型">
          <el-input v-model="form.embeddingModel" placeholder="智谱默认 embedding-2，OpenAI 默认 text-embedding-3-small"/>
        </el-form-item>
        <el-form-item label="视觉模型">
          <el-input v-model="form.visionModel" placeholder="智谱默认 glm-4.6v-flash，OpenAI 默认 gpt-4o"/>
        </el-form-item>
        <el-form-item label="API Key">
          <el-input v-model="form.apiKey" type="password" show-password autocomplete="new-password" placeholder="对话和 Embedding 共用；留空表示不修改已有密钥"/>
        </el-form-item>
        <el-form-item label="优先级">
          <el-input-number v-model="form.priority" :min="1" :max="999"/>
        </el-form-item>
        <el-form-item label="启用">
          <el-switch v-model="form.enabled"/>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取消</el-button>
        <el-button type="primary" @click="save">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import aiConfigApi from '@/api/aiConfig'

const loading = ref(false)
const providers = ref([])
const usage = ref({})
const usageQuery = reactive({ days: 30 })
const dialog = reactive({ visible: false })
const form = reactive({
  id: null,
  providerCode: '',
  providerName: '',
  apiBaseUrl: '',
  chatModel: '',
  embeddingModel: '',
  visionModel: '',
  apiKey: '',
  enabled: false,
  priority: 100
})

const summary = computed(() => usage.value.summary || {})
const isEditing = computed(() => form.id != null)
const successRate = computed(() => {
  const total = Number(summary.value.requestCount || 0)
  if (!total) return '0%'
  return Math.round(Number(summary.value.successCount || 0) * 10000 / total) / 100 + '%'
})

const loadProviders = () => {
  loading.value = true
  aiConfigApi.providers().then(re => {
    providers.value = re.response || []
    loading.value = false
  }).catch(() => {
    loading.value = false
  })
}

const loadUsage = () => {
  aiConfigApi.usage(usageQuery).then(re => {
    usage.value = re.response || {}
  })
}

const resetForm = () => {
  Object.assign(form, {
    id: null,
    providerCode: '',
    providerName: '',
    apiBaseUrl: '',
    chatModel: '',
    embeddingModel: '',
    visionModel: '',
    apiKey: '',
    enabled: false,
    priority: 100
  })
}

const openCreate = () => {
  resetForm()
  dialog.visible = true
}

const openEdit = row => {
  Object.assign(form, {
    id: row.id,
    providerCode: row.providerCode,
    providerName: row.providerName,
    apiBaseUrl: row.apiBaseUrl,
    chatModel: row.chatModel,
    embeddingModel: row.embeddingModel,
    visionModel: row.visionModel,
    apiKey: '',
    enabled: row.enabled,
    priority: row.priority || 100
  })
  dialog.visible = true
}

const save = () => {
  aiConfigApi.saveProvider(form).then(() => {
    ElMessage.success('保存成功')
    dialog.visible = false
    loadProviders()
  })
}

const toggleEnabled = row => {
  aiConfigApi.saveProvider({
    id: row.id,
    providerCode: row.providerCode,
    providerName: row.providerName,
    apiBaseUrl: row.apiBaseUrl,
    chatModel: row.chatModel,
    embeddingModel: row.embeddingModel || embeddingFallback(row.providerCode),
    visionModel: row.visionModel || visionFallback(row.providerCode),
    enabled: row.enabled,
    priority: row.priority || 100,
    apiKey: ''
  }).then(() => {
    ElMessage.success(row.enabled ? '已启用' : '已停用')
    loadProviders()
  }).catch(() => {
    row.enabled = !row.enabled
  })
}

const test = row => {
  aiConfigApi.testProvider(row.id).then(re => {
    const result = re.response || {}
    if (result.success) {
      ElMessage.success(result.message || '连接成功')
    } else {
      ElMessage.error(result.message || '连接失败')
    }
    loadProviders()
  })
}

const deleteProvider = row => {
  aiConfigApi.deleteProvider(row.id).then(re => {
    if (re.code === 1) {
      loadProviders()
      ElMessage.success(re.message)
    }
  })
}

const providerName = code => {
  const p = providers.value.find(p => p.providerCode === code)
  return p ? `${p.providerName}（${code}）` : code
}

const embeddingFallback = providerCode => {
  if (providerCode === 'zhipu') return 'embedding-2'
  if (providerCode === 'openai') return 'text-embedding-3-small'
  return ''
}

const visionFallback = providerCode => {
  if (providerCode === 'zhipu') return 'glm-4.6v-flash'
  if (providerCode === 'openai') return 'gpt-4o'
  return ''
}

const formatCost = value => {
  const n = Number(value || 0)
  return n ? n.toFixed(4) : '0'
}

onMounted(() => {
  loadProviders()
  loadUsage()
})
</script>

<style scoped>
.ai-config-page :deep(.el-card) {
  border-radius: 6px;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-weight: 600;
}

.usage-row {
  margin-top: 16px;
}

.metric-row {
  margin-bottom: 16px;
}

.metric {
  border: 1px solid #ebeef5;
  border-radius: 6px;
  padding: 14px 16px;
  background: #fff;
}

.metric-label {
  color: #606266;
  font-size: 13px;
}

.metric-value {
  margin-top: 8px;
  font-size: 24px;
  font-weight: 600;
  color: #303133;
}
</style>
