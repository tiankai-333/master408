<template>
  <div style="margin-top: 10px" class="app-contain">
    <el-card style="padding-top: 50px;padding-bottom: 50px">
      <div class="el-table__empty-text" style="text-align: center;width: 100%" v-if="total === 0">
        <span>暂无消息</span>
      </div>
      <el-collapse @change="handleChange" class="student-message-list" v-if="total !== 0" accordion>
        <el-collapse-item :name="item.id" :key="item.id" v-for="item in tableData">
          <template #title>
            {{ item.title }}
            <el-tag style="margin: 0 8px 0 auto;" :type="readTagFormat(item.readed)">{{ readTextFormat(item.readed) }}</el-tag>
          </template>
          <el-row><label>发送人：{{ item.sendUserName }}</label></el-row>
          <el-row><label>发送时间：{{ item.createTime }}</label></el-row>
          <el-row><label>发送内容：{{ item.content }}</label></el-row>
        </el-collapse-item>
      </el-collapse>
      <pagination v-show="total > 0" :total="total" :background="false" v-model:page="queryParam.pageIndex"
        :limit="queryParam.pageSize" @pagination="search" style="margin-top: 20px;" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useEnumItemStore } from '@/store/modules/enumItem'
import { useUserStore } from '@/store/modules/user'
import Pagination from '@/components/Pagination/index.vue'
import userApi from '@/api/user'

const enumItemStore = useEnumItemStore()
const userStore = useUserStore()

const readTag = enumItemStore.user.message.readTag
const readText = enumItemStore.user.message.readText

const queryParam = reactive({ pageIndex: 1, pageSize: 10 })
const listLoading = ref(true)
const tableData = ref([])
const total = ref(0)

const readTagFormat = (status) => enumItemStore.enumFormat(readTag, status)
const readTextFormat = (status) => enumItemStore.enumFormat(readText, status)

const handleChange = (val) => {
  if (val === '') return
  const selectItem = tableData.value.filter(d => d.id === val)[0]
  if (!selectItem.readed) {
    userApi.read(val).then(() => {
      selectItem.readed = true
      userStore.messageCountSubtract(1)
    })
  }
}

const search = () => {
  listLoading.value = true
  userApi.messagePageList(queryParam).then(data => {
    const re = data.response
    tableData.value = re.list
    total.value = re.total
    queryParam.pageIndex = re.pageNum
    listLoading.value = false
  })
}

onMounted(() => {
  search()
})
</script>

<style lang="scss"></style>
