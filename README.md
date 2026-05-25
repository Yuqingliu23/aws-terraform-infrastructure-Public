# AWS 负载均衡器基础设施项目

## 项目概述

本项目使用 Terraform 和 GitHub Actions 自动化部署高可用、可扩展的 AWS 负载均衡器基础设施。该基础设施包括网络负载均衡器(NLB)、EC2 实例、安全组、Route53 DNS 记录以及 CloudWatch 监控，通过基础设施即代码(IaC)方式进行管理。

## 系统架构

![架构图](docs/architecture.png)

### 核心组件

- **网络负载均衡器(NLB)**: 分发传入流量到多个可用区中的 EC2 实例
- **EC2 实例**: 多可用区部署的 Web 服务器和 MySQL 数据库服务器
- **CloudWatch 代理**: 收集 EC2 实例的日志和指标
- **Route53**: 提供 DNS 解析，连接用户请求到负载均衡器
- **安全组**: 控制流量的输入和输出
- **自动化流程**: 使用 GitHub Actions 自动部署和销毁资源

## 目录结构

```
.
├── .github/workflows/          # GitHub Actions 工作流配置
│   ├── loadbalancer-deploy.yml # 部署工作流
│   └── loadbalancer-destroy.yml # 销毁工作流
├── terraform/                  # Terraform 配置
│   ├── main.tf                 # 主配置文件
│   ├── outputs.tf              # 输出定义
│   ├── variables.tf            # 变量定义
│   └── modules/                # 模块目录
│       ├── loadbalancer/       # 负载均衡器模块
│       ├── mysql/              # MySQL 模块
│       ├── security/           # 安全配置模块
│       └── web/                # Web 服务器模块
└── README.md                   # 本文档
```

## 环境要求

- AWS 账户和配置凭证
- Terraform 1.5.3 或更高版本
- GitHub Actions 环境（或本地 act 工具用于测试）
- 所需 AWS 权限

## 部署说明

### 环境变量配置

将以下变量配置为 GitHub Secrets 或本地环境变量:

- `AWS_ACCESS_KEY_ID`: AWS 访问密钥 ID
- `AWS_SECRET_ACCESS_KEY`: AWS 密钥
- `AWS_REGION`: AWS 区域（默认 us-east-2）
- `AGENT_WEBAPP_AMI`: Web 服务器 AMI ID
- `AGENT_MYSQL_AMI`: MySQL 服务器 AMI ID
- `DATABASE_USER_NAME`: 数据库用户名
- `DATABASE_PASSWORD`: 数据库密码
- `WEBAPP_SECRET_KEY`: Web 应用密钥
- `EC2_SSH_KEY_NAME`: EC2 SSH 密钥名称
- `ROUTE53_ZONE_ID`: Route53 托管区域 ID
- `DOMAIN_NAME`: 域名

### 自动化部署

1. **使用 GitHub Actions**:
   - 推送代码到 `main` 分支或手动触发工作流
   - GitHub Actions 将自动执行部署

2. **本地测试部署**:
   ```bash
   act --secret-file .env -W .github/workflows/loadbalancer-deploy.yml
   ```

### 手动部署

1. 克隆仓库:
   ```bash
   git clone <仓库 URL>
   cd afnjfm
   ```

2. 初始化 Terraform:
   ```bash
   cd terraform
   terraform init
   ```

3. 部署基础设施:
   ```bash
   terraform apply -var-file=terraform.tfvars
   ```

## 销毁基础设施

1. **使用 GitHub Actions**:
   - 手动触发 `loadbalancer-destroy.yml` 工作流

2. **本地测试销毁**:
   ```bash
   act --secret-file .env -W .github/workflows/loadbalancer-destroy.yml
   ```

3. **手动销毁**:
   ```bash
   cd terraform
   terraform destroy -var-file=terraform.tfvars
   ```

## CloudWatch 监控

负载均衡器基础设施配置了 CloudWatch 代理，用于收集以下指标:

- EC2 实例 CPU、内存、磁盘利用率
- 网络流量统计
- 应用程序日志

## 问题排查

### 常见问题

1. **部署失败 - Terraform 初始化错误**
   - 检查 AWS 凭证和权限
   - 本地测试时，使用离线模式: `terraform init -backend=false`

2. **VPC 依赖关系删除错误**
   - 销毁工作流包含全面的 VPC 依赖清理步骤
   - 对于手动清理，请按照先删除子资源再删除父资源的顺序

3. **CloudWatch 代理配置问题**
   - 确保 IAM 角色正确配置
   - 检查 IMDS 配置允许 IMDSv2

### 调试工具

- 查看 GitHub Actions 工作流日志
- 使用 AWS 控制台检查资源状态
- 查阅 CloudWatch 日志了解详细错误信息

## 安全考虑

- 安全组限制了只有必要端口才开放
- 数据库密码和其他敏感信息通过 GitHub Secrets 安全存储
- EC2 实例使用 IAM 角色而非硬编码凭证