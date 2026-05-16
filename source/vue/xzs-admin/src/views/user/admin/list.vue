<template>
  <div class="app-container">
    <el-form :model="queryParam" ref="queryForm" :inline="true">
      <el-form-item label="用户名：">
        <el-input v-model="queryParam.userName"></el-input>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="submitForm">查询</el-button>
        <router-link :to="{path:'/user/admin/edit'}" class="link-left">
          <el-button type="primary">添加</el-button>
        </router-link>
      </el-form-item>
    </el-form>

    <el-table v-loading="listLoading" :data="tableData" border fit highlight-current-row style="width: 100%">
      <el-table-column prop="id" label="Id" />
      <el-table-column prop="userName" label="用户名"/>
      <el-table-column prop="realName" label="真实姓名" />
      <el-table-column prop="sex" label="性别" width="60px;" :formatter="sexFormatter"/>
      <el-table-column prop="phone" label="手机号"/>
      <el-table-column prop="createTime" label="创建时间" width="160px"/>
      <el-table-column label="状态" prop="status" width="70px">
        <template #default="{row}">
          <el-tag :type="statusTagFormatter(row.status)">
            {{ statusFormatter(row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column width="220px" label="操作" align="center">
        <template #default="{row}">
          <el-button size="mini"   @click="changeStatus(row)" class="link-left">
            {{ statusBtnFormatter(row.status) }}
          </el-button>
          <router-link :to="{path:'/user/admin/edit', query:{id:row.id}}" class="link-left">
            <el-button size="mini">编辑</el-button>
          </router-link>
          <el-button size="mini" type="danger"  @click="deleteUser(row)" class="link-left">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total>0" :total="total" v-model:page="queryParam.pageIndex" v-model:limit="queryParam.pageSize"
                @pagination="search"/>
  </div>
</template>

<script setup>
import { ElMessage } from 'element-plus'
import { reactive, ref, onMounted, computed } from 'vue'
import Pagination from '@/components/Pagination'
import userApi from '@/api/user'
import { useEnumItemStore } from '@/stores/enumItem'

const enumItemStore = useEnumItemStore()

const queryParam = reactive({
  userName: '',
  role: 3,
  pageIndex: 1,
  pageSize: 10
})

const listLoading = ref(true)
const tableData = ref([])
const total = ref(0)

const sexEnum = computed(() => enumItemStore.user.sexEnum)
const statusEnum = computed(() => enumItemStore.user.statusEnum)
const statusTag = computed(() => enumItemStore.user.statusTag)
const statusBtn = computed(() => enumItemStore.user.statusBtn)

const search = () => {
  listLoading.value = true
  userApi.getUserPageList(queryParam).then(data => {
    const re = data.response
    tableData.value = re.list
    total.value = re.total
    queryParam.pageIndex = re.pageNum
    listLoading.value = false
  })
}

const changeStatus = (row) => {
  userApi.changeStatus(row.id).then(re => {
    if (re.code === 1) {
      row.status = re.response
      ElMessage.success(re.message)
    } else {
      ElMessage.error(re.message)
    }
  })
}

const deleteUser = (row) => {
  userApi.deleteUser(row.id).then(re => {
    if (re.code === 1) {
      search()
      ElMessage.success(re.message)
    } else {
      ElMessage.error(re.message)
    }
  })
}

const submitForm = () => {
  queryParam.pageIndex = 1
  search()
}

const sexFormatter = (row, column, cellValue) => {
  return enumItemStore.enumFormat(sexEnum.value, cellValue)
}

const statusFormatter = (status) => {
  return enumItemStore.enumFormat(statusEnum.value, status)
}

const statusTagFormatter = (status) => {
  return enumItemStore.enumFormat(statusTag.value, status)
}

const statusBtnFormatter = (status) => {
  return enumItemStore.enumFormat(statusBtn.value, status)
}

onMounted(() => {
  search()
})
</script>