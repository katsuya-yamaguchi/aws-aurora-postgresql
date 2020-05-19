# 基本的なAWS環境の構築

## 目次
1. [アーキテクチャ](.arch)
2. [セットアップ](.setup)
3. [フォルダ構成](.constitution)

<a class="arch"></a>
## 1. アーキテクチャ
![architecture_web-standard_version1 0](https://user-images.githubusercontent.com/12825529/81499954-e7226080-9309-11ea-8bc2-a8ffb36a31ea.png)

<a class="setup"></a>
## 2. セットアップ
### Dockerイメージの作成
1.環境変数に各種情報を設定する。
```
export AWS_ACCESS_KEY_ID=[アクセスキー]
export AWS_SECRET_ACCESS_KEY=[シークレットキー]
export SECRET_KEY_BASE＝[RailsのSECRET_KEY_BASE]
```

2.Dockerイメージをビルドする。
```
$ docker-compose build
```

### AMI作成Packer & Ansible
#### コンテナへの接続
```
$ docker-compose run --rm app bash
```

#### Packerの実行
```
$ cd /infra/packer

# 文法や設定のチェック
$ /var/tmp/packer validate goldenimage.web.json
→問題なければ「Template validated successfully.」が表示される。

# AMIのビルド
$ /var/tmp/packer build goldenimage.web.json
```

### Terraformの実行
```
$ cd /infra/terraform/[対象のサービス]/env/[dev or prd]

# Terraformの初期化
$ /var/tmp/terraform init

# Terraformのテスト or 実行
$ /var/tmp/terraform plan or apply

※/infra/terraform/ec2/web 配下の実行時に「AMI_IMAGE_ID」を聞かれるので、Packerで作成したAMIのIDを入力する。
```

<a class="Constitution"></a>
## 3. ディレクトリ構成
```
.
├── Dockerfile
├── README.md
├── docker-compose.yml
├── src
   ├── ansible
   │   └── goldenimage.web.yml
   ├── packer
   │   └── goldenimage.web.json
   └── terraform
       ├── ec2
       │   ├── ops
       │   │   ├── env
       │   │   │   ├── dev
       │   │   │   │   └── main.tf
       │   │   │   └── prd
       │   │   └── module
       │   │       └── ec2
       │   │           └── main.tf
       │   └── web
       │       ├── env
       │       │   ├── dev
       │       │   │   ├── main.tf
       │       │   │   └── output.tf
       │       │   └── prd
       │       └── module
       │           ├── ec2
       │           │   ├── main.tf
       │           │   └── userdata.sh
       │           └── elb
       │               ├── main.tf
       │               └── output.tf
       ├── iam
       │   ├── env
       │   │   ├── dev
       │   │   │   ├── main.tf
       │   │   │   └── output.tf
       │   │   └── prd
       │   └── module
       │       └── role
       │           ├── main.tf
       │           └── output.tf
       ├── network
       │   ├── env
       │   │   ├── dev
       │   │   │   ├── main.tf
       │   │   │   ├── output.tf
       │   │   │   └── variable.tf
       │   │   └── prd
       │   └── module
       │       ├── natgateway
       │       │   └── main.tf
       │       ├── route53
       │       │   └── main.tf
       │       ├── security_group
       │       │   ├── main.tf
       │       │   └── output.tf
       │       └── vpc
       │           ├── main.tf
       │           └── output.tf
       ├── rds
       │   ├── env
       │   │   ├── dev
       │   │   │   ├── main.tf
       │   │   │   └── output.tf
       │   │   └── prd
       │   └── module
       │       └── rds
       │           ├── main.tf
       │           └── output.tf
       └── s3
           ├── env
           │   ├── dev
           │   │   ├── main.tf
           │   │   └── output.tf
           │   └── prd
           └── module
               └── s3
                   ├── main.tf
                   └── output.tf

```