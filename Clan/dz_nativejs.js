
;(function(){
  /*初始化webview javascript*/
  function connectWebViewJavascriptBridge(callback) {
  if (window.WebViewJavascriptBridge) {
  callback(WebViewJavascriptBridge)
  } else {
  document.addEventListener('WebViewJavascriptBridgeReady', function() {
                            callback(WebViewJavascriptBridge)
                            }, false)
  }
  }
  
  
  connectWebViewJavascriptBridge(function(bridge) {
                                                                  
                                /*只看楼主*/
                                 bridge.registerHandler('viewAutherOnly', function(data, responseCallback){
                                                        if (typeof BigAppH5.bigApi_h5_viewOnly == 'undefined') {
                                                        alert('只看楼主的bigApi_h5_viewOnly方法不存在');
                                                        } else {
                                                        };
                                                        responseCallback('success');
                                                        BigAppH5.bigApi_h5_viewOnly(data);
                                                        });
                                 /*跳页*/
                                 bridge.registerHandler('jumpAction', function(data, responseCallback){
                                                        if( typeof BigAppH5.bigApi_h5_detailJump == 'undefined' ){
                                                        alert('找不到方法 bigApi_h5_detailJump不存在');
                                                        }else{
                                                        //存在
                                                        }
                                                        responseCallback('success');
                                                        BigAppH5.bigApi_h5_detailJump(data);
                                                        });
                                 /*获取公共信息*/
                                 bridge.registerHandler('getPostData', function(data, responseCallback){
                                                        responseCallback(BigAppH5.postData);
                                                        });
                                 /*获取分享信息*/
                                 bridge.registerHandler('getShareInfo', function(data, responseCallback){
                                                        responseCallback(BigAppH5.shareData);
                                                        });
                                 /*打印源码*/
                                 bridge.registerHandler('printSource', function(data, responseCallback){
                                                        responseCallback(BigAppH5.bigApi_h5_showSource());
                                                        });
                                /*回帖成功*/
                                 bridge.registerHandler('replyPostComplete', function(data, responseCallback){
                                                        responseCallback('success');
                                                        BigAppH5.bigApi_h5_detailReplyMain(data);
                                                        });
                                 /*登录成功*/
                                 bridge.registerHandler('sendLoginNoti', function(data, responseCallback){
                                                        responseCallback('success');
                                                        BigAppH5.bigApi_h5_login(data);
                                                        });
                                 /*退出登录成功*/
                                 bridge.registerHandler('sendLogoutNoti', function(data, responseCallback){
                                                        responseCallback('success');
                                                        BigAppH5.bigApi_h5_logout();
                                                        });
                                 
                                 bridge.init(function(message, responseCallback) {
                                             if (responseCallback) {
                                             responseCallback("Javascript====responseCallback====")
                                             }
                                             
                                             });
                                 });
  
  })();


;(function() {
/*获取环境信息*/
  function getEnvironment() {
  var message = JSON.parse(window.iosNative_getENV);
  return message;
  }
  
/*获取数据*/
  function getData(paras) {
  var bridge = window.WebViewJavascriptBridge;
  bridge.callHandler('getData',paras, function(response) {
                     var key = response.result;
                     var successCallback = paras.success;
                     var errorCallback = paras.error;
                     if (key == 0) {
                     successCallback(response.responsedatas);
                     } else {
                     errorCallback(response.responsedatas);
                     }
                     });
  }
  
    /*点击图片*/
  function clickImage(paras) {
  var bridge = window.WebViewJavascriptBridge;
  var shutViewCallback = paras.shutView;
  var successCallback = paras.success;
  var errorCallback = paras.error;
  try {
		bridge.callHandler('clickImage',paras,function(response) {
                           var key = response.result;
                           if (key == 0) {
                           successCallback(response.responsedatas);
                           
                           }
                           else if (key == 1) {
                           errorCallback(response.responsedatas);
                           }
                           else {
                           //状态码为2 标示关闭了窗口
                           shutViewCallback(response.responsedatas);
                           };
                           });
  } catch(exception) {
		errorCallback({errorMessage:'调用local方法失败'});
  }
  }
  
    /*点击头像*/
  function clickAvatar(paras) {
  var bridge = window.WebViewJavascriptBridge;
  var successCallback = paras.success;
  var errorCallback = paras.error;
  try {
		bridge.callHandler('clickAvatar',paras,function(response) {
                           var key = response.result;
                           if (key == 0) {
                           successCallback(response.responsedatas);
                           
                           } else {
                           errorCallback(response.responsedatas);
                           };
                        });
  } catch(exception) {
		errorCallback({errorMessage:'调用local方法失败'});
  }
  }
  
  /*显示toast提示语*/
  function toast(paras) {
  var bridge = window.WebViewJavascriptBridge;
  bridge.callHandler('showToast',paras,function(response) {
                           });
  }

  
/*作用域名*/
  window.BigAppNative = {
  getEnvironment: getEnvironment,
  getData: getData,
  clickImage: clickImage,
  clickAvatar: clickAvatar,
  toast: toast,
  }
  
  })();