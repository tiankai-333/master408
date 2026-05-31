const {
  $Message
} = require('/component/iView/base/index');
const mtjwxsdk = require('./utils/mtj-wx-sdk.js');

App({
  globalData: {
    baseAPI: "https://wx.hhhuu.com",
    staticBase: "https://wx.hhhuu.com/student/",
    pageSize: 20
  },
  onLaunch: function() {
    let _this = this
    let token = wx.getStorageSync('token')
    if (null == token || token == '') {
      wx.login({
        success(wxres) {
          if (wxres.code) {
            _this.formPost('/api/wx/student/auth/checkBind', {
              "code": wxres.code
            }).then(res => {
              if (res.code == 1) {
                wx.setStorageSync('token', res.response)
                wx.switchTab({
                  url: '/pages/index/index',
                });
              } else if (res.code == 2) {
                wx.reLaunch({
                  url: '/pages/user/bind/index',
                });
              } else {
                _this.message(res.message, 'error')
              }
            }).catch(e => {
              _this.message(e, 'error')
            })
          } else {
            _this.message(wxres.errMsg, 'error')
          }
        }
      })
    }
  },
  message: function(content, type) {
    $Message({
      content: content,
      type: type
    });
  },
  jsonPost: function(url, data) {
    let _this = this
    return new Promise(function(resolve, reject) {
      console.log('[request] POST', _this.globalData.baseAPI + url)
      wx.showNavigationBarLoading();
      wx.request({
        url: _this.globalData.baseAPI + url,
        header: {
          'content-type': 'application/json',
          'token': wx.getStorageSync('token')
        },
        method: 'POST',
        data: data,
        success(res) {
          if (res.statusCode !== 200 || typeof res.data !== 'object') {
            reject('网络出错')
            return false;
          }
          if (res.data.code === 400) {
            let token = res.data.response
            wx.setStorageSync('token', token)
            wx.request({
              url: _this.globalData.baseAPI + url,
              header: {
                'content-type': 'application/json',
                'token': wx.getStorageSync('token')
              },
              method: 'POST',
              data: data,
              success(result) {
                resolve(result.data);
              },
              fail() {
                reject('网络出错')
              }
            })
          } else if (res.data.code === 401) {
            wx.showToast({ title: '登录已过期', icon: 'none', duration: 1500 })
            setTimeout(function() { wx.reLaunch({ url: '/pages/user/bind/index' }) }, 1500)
            return false;
          } else if (res.data.code === 500 || res.data.code === 501) {
            reject(res.data.message)
            return false;
          } else {
            resolve(res.data);
            return true;
          }
        },
        fail(res) {
          reject(res.errMsg)
          return false;
        },
        complete(res) {
          wx.hideNavigationBarLoading();
        }
      })
    })
  },
  formPost: function(url, data) {
    let _this = this
    return new Promise(function(resolve, reject) {
      console.log('[request] POST', _this.globalData.baseAPI + url)
      wx.showNavigationBarLoading();
      wx.request({
        url: _this.globalData.baseAPI + url,
        header: {
          'content-type': 'application/x-www-form-urlencoded',
          'token': wx.getStorageSync('token')
        },
        method: 'POST',
        data,
        success(res) {

          if (res.statusCode !== 200 || typeof res.data !== 'object') {
            reject('网络出错')
            return false;
          }

          if (res.data.code === 400) {
            let token = res.data.response
            wx.setStorageSync('token', token)
            wx.request({
              url: _this.globalData.baseAPI + url,
              header: {
                'content-type': 'application/x-www-form-urlencoded',
                'token': wx.getStorageSync('token')
              },
              method: 'POST',
              data,
              success(result) {
                resolve(result.data);
              },
              fail() {
                reject('网络出错')
              }
            })
          } else if (res.data.code === 401) {
            wx.showToast({ title: '登录已过期', icon: 'none', duration: 1500 })
            setTimeout(function() { wx.reLaunch({ url: '/pages/user/bind/index' }) }, 1500)
          } else if (res.data.code === 500) {
            reject(res.data.message)
            return false;
          } else if (res.data.code === 501) {
            reject(res.data.message)
            return false;
          } else {
            resolve(res.data);
            return true;
          }
        },
        fail(res) {
          reject(res.errMsg)
          return false;
        },
        complete(res) {
          wx.hideNavigationBarLoading();
        }
      })
    })
  },
  uploadFile: function(url, filePath, name) {
    let _this = this
    return new Promise(function(resolve, reject) {
      console.log('[request] UPLOAD', _this.globalData.baseAPI + url)
      wx.uploadFile({
        url: _this.globalData.baseAPI + url,
        filePath: filePath,
        name: name || 'file',
        header: {
          'token': wx.getStorageSync('token')
        },
        success(res) {
          if (res.statusCode !== 200) {
            reject('网络出错')
            return
          }
          let data = res.data
          if (typeof data === 'string') {
            try { data = JSON.parse(data) } catch (e) {
              reject('响应解析失败')
              return
            }
          }
          if (data.code === 401) {
            wx.reLaunch({ url: '/pages/user/bind/index' })
            return
          }
          resolve(data)
        },
        fail(res) {
          reject(res.errMsg)
        }
      })
    })
  }
})
