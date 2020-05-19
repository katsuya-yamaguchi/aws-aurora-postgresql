# 基本的なAWS環境の構築

## 目次
1. [アーキテクチャ](.arch)
2. [セットアップ](.setup)

<a class="arch"></a>
## 1.アーキテクチャ

<a class="setup"></a>
## 2.セットアップ
### Dockerイメージの作成
```
$ docker-compose build
```

### Terraformの実行
```
$ docker-compose run --rm app bash

# aws configure
  -> aws credentialを設定。

# cd /infra/terraform/[対象のサービス]/env/dev

# terraform init
# terraform plan or apply
```
