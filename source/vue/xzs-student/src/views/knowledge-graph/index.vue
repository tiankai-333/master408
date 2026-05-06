<template>
  <div class="knowledge-graph-container">
    <div class="graph-header">
      <div class="header-icon">
        <i class="el-icon-network"></i>
      </div>
      <h2>知识图谱</h2>
      <p>探索知识的关联与结构</p>
    </div>

    <div class="graph-content">
      <div class="sidebar">
        <el-card class="filter-card" shadow="hover">
          <div class="card-header">
            <i class="el-icon-filter"></i>
            <span>筛选条件</span>
          </div>
          
          <el-form :model="filterForm" label-width="80px">
            <el-form-item label="学科">
              <el-select v-model="filterForm.subjectId" placeholder="请选择学科" @change="loadGraph">
                <el-option label="全部" :value="null" />
                <el-option v-for="subject in subjects" :key="subject.id" :label="subject.name" :value="subject.id" />
              </el-select>
            </el-form-item>
          </el-form>
        </el-card>

        <el-card class="info-card" shadow="hover" v-if="selectedNode">
          <div class="card-header">
            <i class="el-icon-info"></i>
            <span>节点详情</span>
          </div>
          <div class="node-info">
            <div class="info-row">
              <span class="info-label">名称：</span>
              <span class="info-value">{{ selectedNode.name }}</span>
            </div>
            <div class="info-row" v-if="selectedNode.type === 'knowledge_point'">
              <span class="info-label">类型：</span>
              <span class="info-value">知识点</span>
            </div>
            <div class="info-row" v-if="selectedNode.type === 'subject'">
              <span class="info-label">类型：</span>
              <span class="info-value">学科</span>
            </div>
            <div class="info-row" v-if="selectedNode.level">
              <span class="info-label">难度：</span>
              <span class="info-value">{{ getLevelText(selectedNode.level) }}</span>
            </div>
            <div class="info-row" v-if="selectedNode.description">
              <span class="info-label">描述：</span>
              <span class="info-value">{{ selectedNode.description }}</span>
            </div>
          </div>
        </el-card>
      </div>

      <div class="main-area">
        <div ref="chartRef" class="graph-chart"></div>
        
        <div class="legend-bar">
          <div class="legend-item">
            <span class="legend-dot subject-dot"></span>
            <span>学科</span>
          </div>
          <div class="legend-item">
            <span class="legend-dot kp-dot"></span>
            <span>知识点</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import * as echarts from 'echarts'
import { get } from '@/utils/request'
import knowledgeGraphApi from '@/api/knowledgeGraph'

export default {
  name: 'KnowledgeGraph',
  data() {
    return {
      filterForm: {
        subjectId: null
      },
      subjects: [],
      selectedNode: null,
      chartInstance: null,
      graphData: {
        nodes: [],
        links: [],
        categories: []
      }
    }
  },
  mounted() {
    this.loadSubjects()
    this.initChart()
    this.loadGraph()

    window.addEventListener('resize', this.handleResize)
  },
  beforeUnmount() {
    window.removeEventListener('resize', this.handleResize)
    if (this.chartInstance) {
      this.chartInstance.dispose()
    }
  },
  methods: {
    async loadSubjects() {
      try {
        const response = await get('/api/student/subject/list')
        if (response.code === 1) {
          this.subjects = response.response || []
        }
      } catch (error) {
        console.error('加载学科失败:', error)
      }
    },
    async loadGraph() {
      try {
        const response = await knowledgeGraphApi.getKnowledgeGraph(this.filterForm.subjectId)
        if (response.code === 1) {
          this.graphData = response.response
          this.renderChart()
        }
      } catch (error) {
        console.error('加载知识图谱失败:', error)
      }
    },
    initChart() {
      const chartDom = this.$refs.chartRef
      if (!chartDom) return

      this.chartInstance = echarts.init(chartDom)
      this.chartInstance.on('click', (params) => {
        if (params.dataType === 'node') {
          this.selectedNode = params.data
        }
      })
    },
    renderChart() {
      if (!this.chartInstance || !this.graphData.nodes.length) return

      const option = {
        backgroundColor: '#f5f7fa',
        tooltip: {
          trigger: 'item',
          formatter: (params) => {
            if (params.dataType === 'node') {
              let html = `<div style="font-weight: bold; margin-bottom: 5px;">${params.name}</div>`
              html += `<div>类型：${params.data.type === 'subject' ? '学科' : '知识点'}</div>`
              if (params.data.level) {
                html += `<div>难度：${this.getLevelText(params.data.level)}</div>`
              }
              if (params.data.description) {
                html += `<div>描述：${params.data.description}</div>`
              }
              return html
            } else if (params.dataType === 'edge') {
              return `<div>${params.data.relation}</div>`
            }
            return ''
          }
        },
        legend: {
          data: this.graphData.categories.map(c => c.name),
          orient: 'vertical',
          right: 20,
          top: 'center'
        },
        animationDuration: 1500,
        animationEasingUpdate: 'quinticInOut',
        series: [
          {
            name: '知识图谱',
            type: 'graph',
            layout: 'force',
            data: this.graphData.nodes.map(node => ({
              name: node.name,
              id: node.id,
              symbolSize: node.symbolSize || 50,
              category: node.category,
              itemStyle: {
                color: node.type === 'subject' ? '#667eea' : '#f59f5f',
                borderColor: '#fff',
                borderWidth: 2
              },
              label: {
                show: true,
                position: 'bottom',
                fontSize: 12
              },
              ...node
            })),
            links: this.graphData.links.map(link => ({
              source: link.source,
              target: link.target,
              lineStyle: {
                color: '#999',
                width: 2,
                curveness: 0.2
              },
              label: {
                show: true,
                formatter: link.relation,
                fontSize: 10
              },
              ...link
            })),
            categories: this.graphData.categories,
            roam: true,
            draggable: true,
            force: {
              repulsion: 500,
              gravity: 0.1,
              edgeLength: [100, 200]
            }
          }
        ]
      }

      this.chartInstance.setOption(option)
    },
    handleResize() {
      if (this.chartInstance) {
        this.chartInstance.resize()
      }
    },
    getLevelText(level) {
      const levelMap = {
        1: '入门',
        2: '基础',
        3: '中等',
        4: '困难',
        5: '挑战'
      }
      return levelMap[level] || '未知'
    }
  }
}
</script>

<style lang="scss" scoped>
.knowledge-graph-container {
  background-color: #f5f7fa;
  min-height: calc(100vh - 70px);
  padding: 30px;
}

.graph-header {
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

.graph-content {
  display: flex;
  gap: 30px;
  max-width: 1600px;
  margin: 0 auto;
}

.sidebar {
  width: 280px;
  flex-shrink: 0;
}

.filter-card, .info-card {
  border: none;
  border-radius: 16px;
  overflow: hidden;
  margin-bottom: 20px;

  .card-header {
    display: flex;
    align-items: center;
    font-size: 16px;
    font-weight: 600;
    color: #1f2f3d;
    padding: 15px 20px;
    background: #fff;
    border-bottom: 1px solid #f0f0f0;

    i {
      margin-right: 10px;
      color: #667eea;
      font-size: 18px;
    }
  }
}

.filter-card {
  .el-form {
    padding: 20px;
  }
}

.info-card {
  .node-info {
    padding: 20px;

    .info-row {
      display: flex;
      margin-bottom: 12px;

      &:last-child {
        margin-bottom: 0;
      }
    }

    .info-label {
      font-weight: 600;
      color: #666;
      min-width: 60px;
    }

    .info-value {
      color: #333;
      flex: 1;
      word-break: break-all;
    }
  }
}

.main-area {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.graph-chart {
  flex: 1;
  min-height: 600px;
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.legend-bar {
  display: flex;
  gap: 30px;
  margin-top: 20px;
  padding: 15px 20px;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);

  .legend-item {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 14px;
    color: #666;
  }

  .legend-dot {
    width: 16px;
    height: 16px;
    border-radius: 50%;

    &.subject-dot {
      background: #667eea;
    }

    &.kp-dot {
      background: #f59f5f;
    }
  }
}

@media screen and (max-width: 992px) {
  .graph-content {
    flex-direction: column;
  }

  .sidebar {
    width: 100%;
  }

  .graph-chart {
    min-height: 400px;
  }
}
</style>