<template>
  <div class="navbar">
    <hamburger id="hamburger-container" :is-active="sidebar.opened" class="hamburger-container" @toggleClick="toggleSideBar" />

    <breadcrumb id="breadcrumb-container" class="breadcrumb-container" />

    <div class="right-menu">
      <el-dropdown class="avatar-container right-menu-item hover-effect" trigger="click">
        <div class="avatar-wrapper">
          <span>{{userName}}</span>
          <i class="el-icon-caret-bottom" />
        </div>
        <el-dropdown-menu slot="dropdown">
          <router-link to="/profile/index">
            <el-dropdown-item>个人信息</el-dropdown-item>
          </router-link>
          <router-link to="/">
            <el-dropdown-item>主页</el-dropdown-item>
          </router-link>
          <el-dropdown-item  @click.native="logout"  divided>退出</el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapMutations } from 'vuex'
import loginApi from '@/api/login'
import Breadcrumb from '@/components/Breadcrumb'
import Hamburger from '@/components/Hamburger'

export default {
  components: {
    Breadcrumb,
    Hamburger
  },
  computed: {
    ...mapGetters([
      'sidebar',
      'device',
      'userName'
    ])
  },
  methods: {
    toggleSideBar () {
      this.$store.dispatch('app/toggleSideBar')
    },
    logout () {
      let _this = this
      loginApi.logout().then(function (result) {
        if (result && result.code === 1) {
          _this.clearLogin()
          _this.$router.push({ path: '/login' })
        }
      })
    },
    ...mapMutations('user', ['clearLogin'])
  }
}
</script>

<style lang="scss" scoped>
.navbar {
  height: 50px;
  overflow: hidden;
  position: relative;
  background: #fff;
  border-bottom: 1px solid #e8eaed;
  box-shadow: 0 1px 6px rgba(0, 21, 41, 0.06);
  display: flex;
  align-items: center;

  .hamburger-container {
    line-height: 46px;
    height: 100%;
    float: left;
    cursor: pointer;
    transition: background 0.2s;
    -webkit-tap-highlight-color: transparent;
    padding: 0 12px;
    border-radius: 6px;

    &:hover {
      background: #f0f7ff;
      color: #1890ff;
    }
  }

  .breadcrumb-container {
    float: left;
    line-height: 50px;
  }

  .errLog-container {
    display: inline-block;
    vertical-align: top;
  }

  .right-menu {
    float: right;
    height: 100%;
    line-height: 50px;
    margin-left: auto;

    &:focus {
      outline: none;
    }

    .right-menu-item {
      display: inline-block;
      padding: 0 8px;
      height: 100%;
      font-size: 18px;
      color: #5a5e66;
      vertical-align: text-bottom;

      &.hover-effect {
        cursor: pointer;
        transition: background 0.2s, color 0.2s;
        border-radius: 6px;

        &:hover {
          background: #f0f7ff;
          color: #1890ff;
        }
      }
    }

    .avatar-container {
      margin-right: 20px;

      .avatar-wrapper {
        display: flex;
        align-items: center;
        gap: 6px;
        padding: 6px 10px;
        border-radius: 8px;
        cursor: pointer;
        transition: background 0.2s, color 0.2s;
        color: #374151;
        font-size: 14px;
        font-weight: 500;

        &:hover {
          background: #f0f7ff;
          color: #1890ff;
        }

        .el-icon-caret-bottom {
          font-size: 12px;
          color: #94a3b8;
          margin-top: 0;
          position: static;
          transform: none;
        }
      }
    }
  }
}
</style>
