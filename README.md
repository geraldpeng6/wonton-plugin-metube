# MeTube 云吞插件

开发流程见[插件开发指南](https://github.com/wontonapp/wonton-docs/blob/main/develop.md)。

[MeTube](https://github.com/alexta69/metube) 的云吞插件（应用许可证 AGPL-3.0-only）：yt-dlp 的网页前端，把网页视频下载到
共享文件夹 `downloads`。网页保留 MeTube 自己的界面（无登录），同时受云吞网关保护；上游界面只有英文，没有多语言。

## 插件做了什么

- 镜像：上游官方 `ghcr.io/alexta69/metube:2026.11.01`，按清单列表（index）摘要固定，支持 amd64 和 arm64。
- 运行身份：`user: "${PUID}:${PGID}"`，镜像不依赖 root（入口脚本检测到非 root 时直接按容器用户运行），下载的文件归主人用户。
- 下载目录：共享文件夹 `downloads`（`storage.share.downloads:write`）挂在 `/downloads`；队列状态和临时文件放在插件自己的
  数据目录（`STATE_DIR=/data/.metube`、`TEMP_DIR=/data/tmp`），共享文件夹里只留下载的文件。
- 网络：`network.egress`，下载要从外网拉视频。
- 登录：`sso: none`。MeTube 没有账号体系也不认 OIDC 或反向代理头，网页在核心网关的登录后面，只有主人打得开。
- 健康检查：`curl http://127.0.0.1:8081/`，检查网页真的能响应。

## 更新上游版本

改 compose 里的标签和摘要（`docker buildx imagetools inspect ghcr.io/alexta69/metube:<新标签>` 取新摘要），改 NOTICE
里图标来源的提交链接（图标变了才需要），走一遍开发指南的检查、安装和冒烟验证。

## 图标来源

`icon.png` 使用 MeTube 官方 `ui/src/assets/icons/android-chrome-384x384.png`（标签 2026.11.01），未用图片模型生成；
来源、处理方式、上游 AGPL-3.0 全文和商标说明见 [NOTICE](NOTICE)。

MeTube 名称和标志是上游项目的商标，权利归相应权利人。本插件是社区适配，不暗示与上游官方合作、关联或获得背书。
