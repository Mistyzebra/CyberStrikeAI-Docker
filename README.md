# CyberStrikeAI Docker 镜像使用指南

> **项目来源与安全提醒**
>
> 本镜像基于开源项目 [CyberStrikeAI](https://github.com/Ed1s0nZ/CyberStrikeAI) 构建，并非官方发布镜像。CyberStrikeAI 涉及网络安全测试、自动化扫描及工具调用能力，请仅在本地实验室、靶场或已获得明确授权的环境中使用。严禁用于未授权目标或任何违法违规活动。建议不要将服务直接暴露到公网，如需远程访问，请结合 VPN、防火墙白名单或反向代理鉴权等措施。

---

## 目录

- [1. 镜像说明](#1-镜像说明)
- [2. 快速开始](#2-快速开始)
  - [克隆仓库](#克隆仓库)
  - [启动容器](#启动容器)
  - [访问服务](#访问服务)
- [3. 配置文件说明](#3-配置文件说明)
  - [模型配置示例](#模型配置示例)
    - [OpenAI](#openai)
    - [DeepSeek](#deepseek)
    - [其他 OpenAI 兼容接口](#其他-openai-兼容接口)
  - [3.3 MCP 配置](#33-mcp-配置)
- [4. 目录与数据持久化](#4-目录与数据持久化)
- [5. 更新与重建镜像](#5-更新与重建镜像)
- [6. 安装额外安全工具](#6-安装额外安全工具)
- [7. 常见问题](#7-常见问题)
  - [7.1 页面无法访问](#71-页面无法访问)
  - [7.2 端口被占用](#72-端口被占用)
  - [7.3 容器启动后立即退出](#73-容器启动后立即退出)
  - [7.4 配置修改后不生效](#74-配置修改后不生效)
  - [7.5 API Key 不生效](#75-api-key-不生效)
  - [7.6 数据目录权限问题](#76-数据目录权限问题)
- [8. 安全建议](#8-安全建议)

---

## 1. 镜像说明

默认镜像名称：

```bash
cyberstrike-ai:local
```

默认容器内路径：

| 项目 | 路径 |
|---|---|
| 应用目录 | `/app` |
| 配置文件 | `/app/config.yaml` |
| 数据目录 | `/app/data` |
| 主程序 | `/app/cyberstrike-ai` |
| Python 虚拟环境 | `/app/venv` |

默认端口：

| 服务 | 容器端口 | 建议宿主机端口 | 说明 |
|---|---:|---:|---|
| Web 服务 | `8080` | `8080` | 浏览器访问入口 |
| MCP 服务 | `8081` | `8081` | 可选，按需启用 |

---

## 2. 快速开始

#### 克隆仓库
```bash
git clone https://github.com/Mistyzebra/CyberStrikeAI-Docker
cd CyberStrikeAI-Docker
```
#### 启动容器

```bash
docker run -d \
  --name cyberstrike-ai \
  -p 8080:8080 \
  -p 8081:8081 \
  -v "$(pwd)/data:/app/data" \
  -v "$(pwd)/config.yaml:/app/config.yaml" \
  cyberstrike-ai:local
```

compose启动
```
docker compose up -d
```
#### 访问服务

浏览器访问：

```text
https://127.0.0.1:8080/
```

远程服务器访问：

```text
https://服务器IP:8080/
```

默认登录密码：

```text
change-me
```


---

## 3. 配置文件说明

容器默认读取：

```text
/app/config.yaml
```

推荐通过挂载宿主机配置文件的方式管理：

```bash
-v "$(pwd)/config.yaml:/app/config.yaml"
```

---


**关键说明**：

| 配置项 | 说明 |
|---|---|
| `server.host` | 必须建议为 `0.0.0.0`，否则宿主机可能无法访问容器内服务 |
| `server.port` | Web 服务监听端口 |
| `auth.enabled` | 是否启用登录认证 |
| `auth.password` | 登录密码 |
| `mcp.enabled` | 是否启用 MCP 服务 |
| `openai.api_key` | 模型 API Key |
| `openai.base_url` | 模型 API 地址 |
| `openai.model` | 模型名称 |

---

### 模型配置示例

#### OpenAI

```yaml
openai:
  api_key: "sk-xxxx"
  base_url: "https://api.openai.com/v1"
  model: "gpt-4o-mini"
```

#### DeepSeek

```yaml
openai:
  api_key: "your-deepseek-api-key"
  base_url: "https://api.deepseek.com/v1"
  model: "deepseek-chat"
```

#### 其他 OpenAI 兼容接口

```yaml
openai:
  api_key: "your-api-key"
  base_url: "https://your-openai-compatible-endpoint/v1"
  model: "your-model-name"
```

修改配置后重启容器：

```bash
docker restart cyberstrike-ai
```

或者：

```bash
docker compose restart
```

---

### 3.3 MCP 配置

如果需要启用 MCP 服务，请修改：

```yaml
mcp:
  enabled: true
  host: "0.0.0.0"
  port: 8081
```

Docker 运行时需要映射端口：

```bash
-p 8081:8081
```

Docker Compose 中需要包含：

```yaml
ports:
  - "8081:8081"
```

修改后重启：

```bash
docker restart cyberstrike-ai
```

---

## 4. 目录与数据持久化

推荐挂载数据目录：

```bash
-v "$(pwd)/data:/app/data"
```

这样即使容器被删除，数据仍会保留在宿主机的 `./data` 目录。

推荐目录结构：

```text
cyberstrike-ai-docker/
├── config.yaml
├── docker-compose.yml
└── data/
```

说明：

| 宿主机路径 | 容器路径 | 作用 |
|---|---|---|
| `./config.yaml` | `/app/config.yaml` | 应用配置 |
| `./data` | `/app/data` | 数据持久化 |

---


## 5. 更新与重建镜像

如果你修改了源代码或 `Dockerfile`，可以重新构建镜像。

在项目源码目录执行：

```bash
docker build -t cyberstrike-ai:local .
```


重建后重启容器：

```bash
docker stop cyberstrike-ai
docker rm cyberstrike-ai
```

然后重新运行：

```bash
docker run -d \
  --name cyberstrike-ai \
  -p 8080:8080 \
  -p 8081:8081 \
  cyberstrike-ai:local
```

如果使用 Docker Compose：

```bash
docker compose down
docker compose up -d
```

如果 `docker-compose.yml` 中包含 `build: .`，可以使用：

```bash
docker compose up -d --build
```

---

## 6. 安装额外安全工具

详见源项目
https://github.com/Ed1s0nZ/CyberStrikeAI

---

## 7. 常见问题

### 7.1 页面无法访问

检查容器是否运行：

```bash
docker ps
```

查看日志：

```bash
docker logs -f cyberstrike-ai
```

确认 `config.yaml` 中：

```yaml
server:
  host: "0.0.0.0"
```

如果配置为 `127.0.0.1`，宿主机可能无法访问容器内服务。

---

### 7.2 端口被占用

如果宿主机 `8080` 已被占用，可以改为：

```bash
docker run -d \
  --name cyberstrike-ai \
  -p 18080:8080 \
  -p 18081:8081 \
  cyberstrike-ai:local
```

访问：

```text
http://127.0.0.1:18080/
```

Docker Compose 示例：

```yaml
ports:
  - "18080:8080"
  - "18081:8081"
```

---

### 7.3 容器启动后立即退出

查看日志：

```bash
docker logs cyberstrike-ai
```

常见原因：

- `config.yaml` 格式错误
- 配置文件未正确挂载
- 应用监听地址配置错误
- 容器内缺少运行依赖
- 数据目录权限不足
- 端口冲突
- 模型 API 配置异常

检查文件：

```bash
ls -l config.yaml
ls -ld data
```

---

### 7.4 配置修改后不生效

修改配置后需要重启容器：

```bash
docker restart cyberstrike-ai
```

或：

```bash
docker compose restart
```

确认容器内配置是否更新：

```bash
docker exec -it cyberstrike-ai cat /app/config.yaml
```

---

### 7.5 API Key 不生效

检查配置：

```yaml
openai:
  api_key: "your-api-key"
  base_url: "https://api.deepseek.com/v1"
  model: "deepseek-chat"
```

确认：

- API Key 没有多余空格
- `base_url` 地址正确
- `model` 名称正确
- 服务商账号余额或权限正常
- 修改后已经重启容器

---

### 7.6 数据目录权限问题

如果日志中出现权限错误，可以执行：

```bash
chmod -R 755 data
```

或：

```bash
sudo chown -R $(id -u):$(id -g) data
```

然后重启：

```bash
docker restart cyberstrike-ai
```

---

## 8. 安全建议

1. 仅在授权环境中使用。
2. 不要将服务直接暴露到公网。
3. 首次启动后立即修改默认密码。
4. 不要把包含 API Key 的 `config.yaml` 提交到 Git 仓库。
5. 建议通过 VPN、堡垒机或反向代理鉴权后访问。
6. 如果部署在服务器上，建议限制来源 IP。
7. 定期查看容器日志。
8. 定期备份 `data` 目录。
9. 不建议在生产业务服务器上直接运行未经审计的安全测试工具。
10. MCP 服务如非必要，建议保持关闭。

---
