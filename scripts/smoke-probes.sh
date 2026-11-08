# scripts/dev.sh smoke 的一项一项探测，跟着插件走。没写的项会 FAIL 并给出写法，不会默认放行。
# shellcheck shell=bash disable=SC2034
#
# 页面：web_assert 从标准输入读页面，命中的确是应用的真实页面时返回 0。
# 身份：MeTube 没有账号体系也不认代登录头（sso: none，网关把关），写 IDENTITY_NA=1 并写明原因。

web_assert() { grep -qi 'metube'; }   # stdin：应用真实页面

IDENTITY_NA=1
# MeTube 自身不持久化任何数据：下载队列在内存里，成品文件直接写进主人的 downloads 共享目录，
# 插件没有自己的存储（清单也没有 WONTON_APP_DATA 卷），升级/重装两项记 N/A。
DATA_NA=1
SMOKE_NOTE="MeTube 无账号体系（网关把关），身份项 N/A；应用自身不持久化（队列在内存，成品进 downloads 共享目录），数据两项 N/A。"
