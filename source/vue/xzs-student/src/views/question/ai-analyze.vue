<template>
  <div class="ai-analyze-container">
    <div class="ai-header">
      <div class="ai-icon">
        <i class="el-icon-search"></i>
      </div>
      <h1>AI题目识别</h1>
      <p>上传题目图片，AI将自动识别题目内容</p>
    </div>

    <div class="ai-content">
      <div class="upload-section">
        <div 
          class="upload-area" 
          :class="{ 'is-dragover': isDragover }"
          @dragover.prevent="handleDragOver"
          @dragleave.prevent="handleDragLeave"
          @drop.prevent="handleDrop"
          @click="triggerFileInput"
        >
          <input 
            ref="fileInput" 
            type="file" 
            accept="image/*" 
            class="file-input"
            @change="handleFileChange"
          />
          <div class="upload-icon">
            <i class="el-icon-upload"></i>
          </div>
          <p class="upload-text">点击或拖拽图片到此处上传</p>
          <p class="upload-hint">支持 JPG、PNG、GIF 格式，单个文件不超过 10MB</p>
        </div>

        <div v-if="previewImage" class="preview-section">
          <h3>图片预览</h3>
          <img :src="previewImage" class="preview-image" />
          <button class="el-button el-button--danger el-button--small" @click="clearImage">
            <i class="el-icon-delete"></i> 清除图片
          </button>
        </div>
      </div>

      <div class="result-section">
        <div class="result-header">
          <h2>识别结果</h2>
          <button 
            v-if="previewImage" 
            class="el-button el-button--primary"
            :loading="isAnalyzing"
            @click="analyzeImage"
          >
            <i class="el-icon-brain"></i> 开始识别
          </button>
        </div>

        <div v-if="analysisResults.length > 0" class="result-content">
          <div class="result-count">
            <i class="el-icon-document"></i>
            共识别到 {{ analysisResults.length }} 道题目
          </div>
          <div v-for="(result, index) in analysisResults" :key="index" class="result-card">
            <div class="question-number">第 {{ index + 1 }} 题</div>
            <div class="result-item">
              <span class="result-label">题目类型：</span>
              <span class="result-value">{{ result.questionType }}</span>
            </div>
            <div class="result-item">
              <span class="result-label">题目内容：</span>
              <span class="result-value">{{ result.title }}</span>
            </div>
            <div v-if="result.options && result.options.length > 0" class="result-item">
              <span class="result-label">选项：</span>
              <div class="options-list">
                <div v-for="(option, optIndex) in result.options" :key="optIndex" class="option-item">
                  {{ option }}
                </div>
              </div>
            </div>
            <div v-if="result.correct" class="result-item">
              <span class="result-label">正确答案：</span>
              <span class="result-value correct-answer">{{ result.correct }}</span>
            </div>
            <div v-if="result.analyze" class="result-item">
              <span class="result-label">解析：</span>
              <span class="result-value">{{ result.analyze }}</span>
            </div>
          </div>
        </div>

        <div v-else-if="!previewImage" class="empty-result">
          <i class="el-icon-image"></i>
          <p>请先上传题目图片</p>
        </div>

        <div v-if="errorMessage" class="error-message">
          <i class="el-icon-error"></i>
          {{ errorMessage }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import questionApi from '@/api/question'

export default {
  name: 'AiAnalyze',
  data () {
    return {
      isDragover: false,
      previewImage: null,
      isAnalyzing: false,
      analysisResults: [],
      errorMessage: null
    }
  },
  methods: {
    triggerFileInput () {
      this.$refs.fileInput.click()
    },
    handleFileChange (event) {
      const file = event.target.files[0]
      if (file) {
        this.processFile(file)
      }
    },
    handleDragOver () {
      this.isDragover = true
    },
    handleDragLeave () {
      this.isDragover = false
    },
    handleDrop (event) {
      this.isDragover = false
      const file = event.dataTransfer.files[0]
      if (file && file.type.startsWith('image/')) {
        this.processFile(file)
      }
    },
    processFile (file) {
      const maxSize = 10 * 1024 * 1024
      if (file.size > maxSize) {
        this.$message.error('图片大小不能超过10MB')
        return
      }

      const reader = new FileReader()
      reader.onload = (e) => {
        this.previewImage = e.target.result
        this.analysisResult = null
        this.errorMessage = null
      }
      reader.readAsDataURL(file)
    },
    clearImage () {
      this.previewImage = null
      this.analysisResults = []
      this.errorMessage = null
      this.$refs.fileInput.value = ''
    },
    async analyzeImage () {
      if (!this.previewImage) {
        this.$message.warning('请先上传图片')
        return
      }

      this.isAnalyzing = true
      this.errorMessage = null
      this.analysisResults = []

      try {
        const fileInput = this.$refs.fileInput
        const file = fileInput.files[0]
        
        const formData = new FormData()
        formData.append('file', file)

        const response = await questionApi.analyzeImage(formData)
        
        console.log('API Response:', response)
        
        if (response.code === 1) {
          if (!response.response || response.response.trim() === '') {
            this.errorMessage = 'AI返回内容为空'
            return
          }
          
          try {
            const rawResult = JSON.parse(response.response)
            console.log('Parsed Result:', rawResult)
            
            if (Array.isArray(rawResult)) {
              this.analysisResults = rawResult.map(item => this.parseQuestionItem(item))
            } else {
              this.analysisResults = [this.parseQuestionItem(rawResult)]
            }
            
            if (this.analysisResults.length === 0 || !this.analysisResults[0].title || this.analysisResults[0].title.trim() === '') {
              this.errorMessage = 'AI未识别到题目内容，请确保图片清晰且包含题目信息'
              this.analysisResults = []
              return
            }
          } catch (parseError) {
            console.log('JSON parse error:', parseError)
            this.analysisResults = [{
              questionType: '未知',
              title: response.response,
              options: [],
              correct: '',
              analyze: ''
            }]
          }
        } else {
          this.errorMessage = response.message || '识别失败'
        }
      } catch (error) {
        console.log('Request error:', error)
        this.errorMessage = '识别失败：' + (error.message || '网络错误')
      } finally {
        this.isAnalyzing = false
      }
    },
    parseQuestionItem (item) {
      const result = {
        questionType: item['题目类型'] || item.questionType || '未知',
        title: item['题目内容'] || item['题干'] || item.title || item.content || item.question || '',
        options: item['选项'] || item.options || [],
        correct: item['正确答案'] || item.correct || '',
        analyze: item['解析'] || item.analyze || ''
      }
      
      if (typeof result.options === 'string') {
        result.options = result.options.split(/[\\n,，；;]/).filter(opt => opt.trim())
      } else if (typeof result.options === 'object' && !Array.isArray(result.options)) {
        result.options = Object.entries(result.options).map(([key, value]) => key + '、' + value)
      }
      
      return result
    }
  }
}
</script>

<style lang="scss" scoped>
.ai-analyze-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 40px 20px;
}

.ai-header {
  text-align: center;
  color: #fff;
  margin-bottom: 40px;

  .ai-icon {
    width: 80px;
    height: 80px;
    background: rgba(255, 255, 255, 0.2);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 20px;

    i {
      font-size: 40px;
    }
  }

  h1 {
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

.ai-content {
  max-width: 900px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 30px;
}

.upload-section {
  background: #fff;
  border-radius: 16px;
  padding: 30px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
}

.upload-area {
  border: 3px dashed #ddd;
  border-radius: 12px;
  padding: 40px 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
  background: #fafafa;

  &:hover {
    border-color: #667eea;
    background: #f5f7fa;
  }

  &.is-dragover {
    border-color: #667eea;
    background: #eef1f8;
    transform: scale(1.02);
  }
}

.file-input {
  display: none;
}

.upload-icon {
  width: 60px;
  height: 60px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 15px;

  i {
    font-size: 30px;
    color: #fff;
  }
}

.upload-text {
  font-size: 16px;
  font-weight: 500;
  color: #333;
  margin: 0 0 8px;
}

.upload-hint {
  font-size: 13px;
  color: #999;
  margin: 0;
}

.preview-section {
  margin-top: 25px;
  text-align: center;

  h3 {
    font-size: 16px;
    font-weight: 600;
    color: #333;
    margin: 0 0 15px;
  }

  .preview-image {
    max-width: 100%;
    max-height: 300px;
    border-radius: 8px;
    object-fit: contain;
    border: 1px solid #eee;
  }

  .el-button {
    margin-top: 15px;
  }
}

.result-section {
  background: #fff;
  border-radius: 16px;
  padding: 30px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
}

.result-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
  padding-bottom: 15px;
  border-bottom: 2px solid #f0f0f0;

  h2 {
    font-size: 20px;
    font-weight: 600;
    color: #333;
    margin: 0;
  }
}

.result-content {
  flex: 1;
  max-height: 600px;
  overflow-y: auto;
}

.result-count {
  display: flex;
  align-items: center;
  padding: 12px 15px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 8px;
  color: #fff;
  font-size: 14px;
  font-weight: 500;
  margin-bottom: 20px;

  i {
    margin-right: 8px;
  }
}

.result-card {
  background: #fafafa;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 20px;
  border: 1px solid #e8e8e8;
  position: relative;

  &:last-child {
    margin-bottom: 0;
  }
}

.question-number {
  position: absolute;
  top: -12px;
  left: 20px;
  background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%);
  color: #fff;
  font-size: 12px;
  font-weight: 600;
  padding: 4px 12px;
  border-radius: 15px;
}

.result-item {
  margin-bottom: 15px;

  &:last-child {
    margin-bottom: 0;
  }
}

.result-label {
  font-size: 14px;
  font-weight: 600;
  color: #666;
  display: block;
  margin-bottom: 5px;
}

.result-value {
  font-size: 15px;
  color: #333;
  line-height: 1.6;
}

.correct-answer {
  color: #67c23a;
  font-weight: 600;
}

.options-list {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.option-item {
  background: #fff;
  padding: 8px 15px;
  border-radius: 20px;
  font-size: 14px;
  color: #333;
  border: 1px solid #e8e8e8;
}

.empty-result {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #999;
  padding: 60px 0;

  i {
    font-size: 60px;
    margin-bottom: 20px;
    opacity: 0.5;
  }

  p {
    font-size: 16px;
    margin: 0;
  }
}

.error-message {
  background: #fef0f0;
  border: 1px solid #fbc4c4;
  border-radius: 8px;
  padding: 15px;
  color: #f56c6c;
  font-size: 14px;
  margin-top: 15px;
  display: flex;
  align-items: center;

  i {
    margin-right: 10px;
  }
}

@media screen and (max-width: 768px) {
  .ai-content {
    grid-template-columns: 1fr;
  }

  .ai-header h1 {
    font-size: 26px;
  }
}
</style>