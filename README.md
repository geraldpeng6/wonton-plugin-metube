# MeTube 云吞插件

[MeTube](https://github.com/alexta69/metube) 的云吞插件（应用许可证 AGPL-3.0-only）：yt-dlp 的网页前端，把网页视频下载到
共享文件夹 `downloads`。网页保留 MeTube 自己的界面（无登录），同时受云吞网关保护；上游界面只有英文，没有多语言。

这个仓库把它做成云吞（Wonton）的插件：一个 `docker-compose.yml`，顶层多一个 `x-wonton` 字段，写明插件在云吞里的身份、
网页入口和要的权限。一个插件一个 Git 仓库，仓库根目录就是插件包，发布就是打 tag。用户在 App 里装上插件，核心按清单起
容器、接好登录，插件的网页在 App 里作为小程序打开。

## 图标来源

`icon.png` 使用 MeTube 官方 `ui/src/assets/icons/android-chrome-384x384.png`（标签 2026.11.01），未用图片模型生成；
来源、处理方式、上游 AGPL-3.0 全文和商标说明见 [NOTICE](NOTICE)。

MeTube 名称和标志是上游项目的商标，权利归相应权利人。本插件是社区适配，不暗示与上游官方合作、关联或获得背书。

## 准备

- Docker Engine 28 或更新的版本，带 Compose 插件（`docker compose`）。Linux 上的 Docker Engine、macOS 上的 Docker Desktop 和
  OrbStack 都行。
- `git`、`curl`（7.76 或更新）、`python3`。
- Docker 要在本机：开发环境的数据目录是这个仓库下的路径，网页也开在本机的端口上。在远程主机上开发见后面的
  “在远程主机上开发”。

不用装云吞，也不要 root：脚本用发布的核心镜像（`ghcr.io/geraldpeng6/wonton-core`）检查插件、起开发环境。

## 先跑起来

```bash
scripts/dev.sh up
```

```bash
scripts/dev.sh install
```

`up` 在本机起一套云吞，打印它的地址，如 `http://hello3f2a.wonton.localhost:21234/`。浏览器打开，用
`scripts/dev.sh token` 输出的用户令牌登录。`install` 先列出插件要的权限，确认后装上，打印插件网页的地址；打开就是
MeTube 的下载页，贴上视频网址就能下载，文件落在共享文件夹 `downloads`。Chrome、Firefox 和 curl 把 `*.localhost`
直接解析到本机，不用改 hosts。

## 仓库里有什么

| 路径 | 内容 |
| --- | --- |
| `docker-compose.yml` | 插件本身：compose 加上 `x-wonton` 清单 |
| `icon.png` | 上游官方标志，白底 512×512 PNG（清单引用） |
| `screenshots/` | 商店详情页里的截图 |
| `scripts/check.sh` | 检查插件包，规则和安装时一样 |
| `scripts/dev.sh` | 开发环境：起一套云吞，装、重装、卸载插件，看日志 |
| `scripts/publish.sh` | 发布一个版本：打 tag、推送 |
| `AGENTS.md` | 给人和 AI 编程代理的规则 |
| `.wonton/` | 开发环境的设置、密钥和数据，不提交 |

插件包是 `docker-compose.yml` 加上它引用的文件：`icon`、`notices` 和顶层 `configs` 的 `file`。README、
截图、Dockerfile、源码都不在插件包里，核心不取。引用的路径相对仓库根目录，不能是绝对路径、不能含 `..`、不能用变量，
也不能经过软链接；单个文件不超过 1 MiB，整个插件包不超过 2 MiB。

## 插件做了什么

- 镜像：上游官方 `ghcr.io/alexta69/metube:2026.11.01`，按清单列表（index）摘要固定，支持 amd64 和 arm64。
- 运行身份：`user: "${PUID}:${PGID}"`，镜像不依赖 root（入口脚本检测到非 root 时直接按容器用户运行），下载的文件归主人用户。
- 下载目录：共享文件夹 `downloads`（`storage.share.downloads:write`）挂在 `/downloads`；队列状态和临时文件放在插件自己的
  数据目录（`STATE_DIR=/data/.metube`、`TEMP_DIR=/data/tmp`），共享文件夹里只留下载的文件。
- 网络：`network.egress`，下载要从外网拉视频。
- 登录：`sso: none`。MeTube 没有账号体系也不认 OIDC 或反向代理头，网页在核心网关的登录后面，只有主人打得开。
- 健康检查：`curl http://127.0.0.1:8081/`，检查网页真的能响应。

## 开发环境

| 命令 | 做什么 |
| --- | --- |
| `scripts/dev.sh up` | 起开发环境，等到都健康；再执行一次就是拉最新的核心镜像重启（`WONTON_PULL=never` 时不拉） |
| `scripts/dev.sh install [--yes] [<git 引用>]` | 预览、确认后安装；给了 tag、分支或提交就装那个版本 |
| `scripts/dev.sh reinstall [--yes]` | 装着就先卸载（保留数据），再装上工作区里的 |
| `scripts/dev.sh uninstall [--purge]` | 卸载；`--purge` 连插件的数据一起删 |
| `scripts/dev.sh status` | 开发环境的服务和装着的插件 |
| `scripts/dev.sh logs [<服务>]` | 跟着看核心的日志；给了插件的服务名就看那个服务的 |
| `scripts/dev.sh token` | 主人令牌 |
| `scripts/dev.sh web [<路径> [<curl 参数>…]]` | 以主人的身份请求插件网页上的地址 |
| `scripts/dev.sh smoke` | 合并前的端到端冒烟 |
| `scripts/dev.sh down` | 停下，数据都留着 |
| `scripts/dev.sh purge` | 删掉整个开发环境 |

## 检查

```bash
scripts/check.sh --official
```

按官方商店的要求检查插件包：清单解析、商店信息、图标和截图。镜像没按摘要固定、没有健康检查、没有图标在这里都算不合格。

## 发布

发布只用 `scripts/publish.sh`：先改清单的 `version`、写好 `release_notes`，确认 `notices` 是最新的，提交后执行。
发布过的 tag 不移动、不删除。更新上游版本时：改 compose 里的标签和摘要（`docker buildx imagetools inspect
ghcr.io/alexta69/metube:<新标签>` 取新摘要），改 NOTICE 里图标来源的提交链接（图标变了才需要），走一遍上面的验证。

## 规则以哪里为准

这里是[插件规范](https://github.com/geraldpeng6/wonton-docs/blob/main/plugin-spec.md) `x-wonton` 的写插件指南，完整规则和理由在规范里。
规范和核心一起演进；说法对不上时以核心的检查为准：`scripts/check.sh` 通过、`scripts/dev.sh install` 装得上，插件包才算写对了。
