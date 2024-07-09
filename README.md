# terraform-provider-mysql-play-petoju

https://ruan.dev/blog/2023/07/15/how-to-use-the-mysql-terraform-provider を動かしてみる。

## 1. 一通り動かす

書いてあるとおりapplyしてdatabase, userを作ってログインしてみる。
passwordのrotateが簡単にできるのは便利。

```shell
❯ docker exec -it mysql mysql -u root -prootpassword -e 'show databases;'
mysql: [Warning] Using a password on the command line interface can be insecure.
+--------------------+
| Database           |
+--------------------+
| foobar             |
| information_schema |
| mysql              |
| performance_schema |
| sample             |
| sys                |
+--------------------+

❯ DBPASS=$(terraform output -raw password)

❯ docker exec -it mysql mysql -u ruanb -p$DBPASS -e 'show databases;'
mysql: [Warning] Using a password on the command line interface can be insecure.
+--------------------+
| Database           |
+--------------------+
| foobar             |
| information_schema |
| performance_schema |
+--------------------+

# passwod rotate
❯ terraform apply -auto-approve -var password_version=2
❯ DBPASS=$(terraform output -raw password)

```

## 2. stateファイルの中身

純粋にtf state showで見てみる。

```shell
❯ tf state list
mysql_database.user_db
mysql_grant.user_id
mysql_user.user_id
random_password.user_password

❯ tf state show random_password.user_password
# random_password.user_password:
resource "random_password" "user_password" {
    bcrypt_hash      = (sensitive value)
    id               = "none"
    keepers          = {
        "password_version" = "1"
    }
    length           = 24
    lower            = true
    min_lower        = 0
    min_numeric      = 0
    min_special      = 2
    min_upper        = 0
    number           = true
    numeric          = true
    override_special = "!#$%&()*+_-=[]{}<>:?"
    result           = (sensitive value)
    special          = true
    upper            = true
}

❯ tf state show mysql_database.user_db
# mysql_database.user_db:
resource "mysql_database" "user_db" {
    default_character_set = "utf8mb4"
    default_collation     = "utf8mb4_general_ci"
    id                    = "foobar"
    name                  = "foobar"
}

❯ tf state show mysql_grant.user_id
# mysql_grant.user_id:
resource "mysql_grant" "user_id" {
    database   = "foobar"
    grant      = false
    host       = "%"
    id         = "ruanb@%:`foobar`"
    privileges = [
        "SELECT",
        "UPDATE",
    ]
    roles      = []
    table      = "*"
    tls_option = "NONE"
    user       = "ruanb"
}

❯ tf state show mysql_user.user_id
# mysql_user.user_id:
resource "mysql_user" "user_id" {
    auth_plugin        = "caching_sha2_password"
    auth_string_hashed = (sensitive value)
    host               = "%"
    id                 = "ruanb@%"
    plaintext_password = (sensitive value)
    tls_option         = "NONE"
    user               = "ruanb"
}

```

terraform.tfstateの中身はこんな感じ。

```json
❯ cat terraform.tfstate
{
  "version": 4,
  "terraform_version": "1.5.7",
  "serial": 15,
  "lineage": "e5b12300-4054-6f96-68d9-ee76cd681804",
  "outputs": {
    "password": {
      "value": ":_rv}=x1k\u003c%7xOTeTjEDSkJy",
      "type": "string",
      "sensitive": true
    },
    "user": {
      "value": "ruanb",
      "type": "string"
    }
  },
  "resources": [
    {
      "mode": "managed",
      "type": "mysql_database",
      "name": "user_db",
      "provider": "provider[\"registry.terraform.io/petoju/mysql\"].local",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "default_character_set": "utf8mb4",
            "default_collation": "utf8mb4_general_ci",
            "id": "foobar",
            "name": "foobar"
          },
          "sensitive_attributes": [],
          "private": "bnVsbA=="
        }
      ]
    },
    {
      "mode": "managed",
      "type": "mysql_grant",
      "name": "user_id",
      "provider": "provider[\"registry.terraform.io/petoju/mysql\"].local",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "database": "foobar",
            "grant": false,
            "host": "%",
            "id": "ruanb@%:`foobar`",
            "privileges": [
              "SELECT",
              "UPDATE"
            ],
            "role": null,
            "roles": [],
            "table": "*",
            "tls_option": "NONE",
            "user": "ruanb"
          },
          "sensitive_attributes": [],
          "private": "bnVsbA==",
          "dependencies": [
            "mysql_user.user_id",
            "random_password.user_password"
          ]
        }
      ]
    },
    {
      "mode": "managed",
      "type": "mysql_user",
      "name": "user_id",
      "provider": "provider[\"registry.terraform.io/petoju/mysql\"].local",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "aad_identity": [],
            "auth_plugin": "caching_sha2_password",
            "auth_string_hashed": "$A$005$\\n_\u0011n\u000e\u0018\\Z*;g:m-4\\ZN\u0013q\u000c DtGCQyyg2H3mDAHgXM2mqD57yH/NPh3xX1T2jSKvw0A",
            "host": "%",
            "id": "ruanb@%",
            "password": null,
            "plaintext_password": "95d40ac9739b5f8dc941d14a064dd00a690a4a19fb35f45ef5fb0bd06c7d66e8",
            "tls_option": "NONE",
            "user": "ruanb"
          },
          "sensitive_attributes": [
            [
              {
                "type": "get_attr",
                "value": "plaintext_password"
              }
            ]
          ],
          "private": "bnVsbA==",
          "dependencies": [
            "random_password.user_password"
          ]
        }
      ]
    },
    {
      "mode": "managed",
      "type": "random_password",
      "name": "user_password",
      "provider": "provider[\"registry.terraform.io/hashicorp/random\"]",
      "instances": [
        {
          "schema_version": 3,
          "attributes": {
            "bcrypt_hash": "$2a$10$O3GSP/L0629huWi68MDmveRPPl727PVkwApRGpwBzSUnjrD9n3vZu",
            "id": "none",
            "keepers": {
              "password_version": "1"
            },
            "length": 24,
            "lower": true,
            "min_lower": 0,
            "min_numeric": 0,
            "min_special": 2,
            "min_upper": 0,
            "number": true,
            "numeric": true,
            "override_special": "!#$%\u0026()*+_-=[]{}\u003c\u003e:?",
            "result": ":_rv}=x1k\u003c%7xOTeTjEDSkJy",
            "special": true,
            "upper": true
          },
          "sensitive_attributes": []
        }
      ]
    }
  ],
  "check_results": null
}

```

最初にoutput value。passwordはぱっと見平文ではなさそう。

```json
"outputs": {
    "password": {
      "value": ":_rv}=x1k\u003c%7xOTeTjEDSkJy",
      "type": "string",
      "sensitive": true
    },
    "user": {
      "value": "ruanb",
      "type": "string"
    }
  },
```

それ以降はリソース本体。tfstateのスキーマは初めて見たけど、instances.attributesにリソースの属性が入っている。

### database

```json
    {
      "mode": "managed",
      "type": "mysql_database",
      "name": "user_db",
      "provider": "provider[\"registry.terraform.io/petoju/mysql\"].local",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "default_character_set": "utf8mb4",
            "default_collation": "utf8mb4_general_ci",
            "id": "foobar",
            "name": "foobar"
          },
          "sensitive_attributes": [],
          "private": "bnVsbA=="
        }
      ]
    },
```

論理databaseにセンシティブなデータは入ってないので特段きにするものはない。

### dbuser

```json
{
      "mode": "managed",
      "type": "mysql_user",
      "name": "user_id",
      "provider": "provider[\"registry.terraform.io/petoju/mysql\"].local",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "aad_identity": [],
            "auth_plugin": "caching_sha2_password",
            "auth_string_hashed": "$A$005$\\n_\u0011n\u000e\u0018\\Z*;g:m-4\\ZN\u0013q\u000c DtGCQyyg2H3mDAHgXM2mqD57yH/NPh3xX1T2jSKvw0A",
            "host": "%",
            "id": "ruanb@%",
            "password": null,
            "plaintext_password": "95d40ac9739b5f8dc941d14a064dd00a690a4a19fb35f45ef5fb0bd06c7d66e8",
            "tls_option": "NONE",
            "user": "ruanb"
          },
          "sensitive_attributes": [
            [
              {
                "type": "get_attr",
                "value": "plaintext_password"
              }
            ]
          ],
          "private": "bnVsbA==",
          "dependencies": [
            "random_password.user_password"
          ]
        }
      ]
    },

```

> plaintext_password - (Optional) The password for the user. This must be provided in plain text, so the data source for it must be secured. An unsalted hash of the provided password is stored in state. Conflicts with auth_plugin.

> auth_string_hashed - (Optional) Use an already hashed string as a parameter to auth_plugin. This can be used with passwords as well as with other auth strings.

fork元の参照だけど、passwordが平文でtfsateに含まれることになるので、注意が必要。
https://registry.terraform.io/providers/icy/mysql/latest/docs/resources/user

### grant

```json
{
      "mode": "managed",
      "type": "mysql_grant",
      "name": "user_id",
      "provider": "provider[\"registry.terraform.io/petoju/mysql\"].local",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "database": "foobar",
            "grant": false,
            "host": "%",
            "id": "ruanb@%:`foobar`",
            "privileges": [
              "SELECT",
              "UPDATE"
            ],
            "role": null,
            "roles": [],
            "table": "*",
            "tls_option": "NONE",
            "user": "ruanb"
          },
          "sensitive_attributes": [],
          "private": "bnVsbA==",
          "dependencies": [
            "mysql_user.user_id",
            "random_password.user_password"
          ]
        }
      ]
    },
```

こちらもdatabase同様、特にセンシティブなデータはない。

### random_password

```json
{
      "mode": "managed",
      "type": "random_password",
      "name": "user_password",
      "provider": "provider[\"registry.terraform.io/hashicorp/random\"]",
      "instances": [
        {
          "schema_version": 3,
          "attributes": {
            "bcrypt_hash": "$2a$10$O3GSP/L0629huWi68MDmveRPPl727PVkwApRGpwBzSUnjrD9n3vZu",
            "id": "none",
            "keepers": {
              "password_version": "1"
            },
            "length": 24,
            "lower": true,
            "min_lower": 0,
            "min_numeric": 0,
            "min_special": 2,
            "min_upper": 0,
            "number": true,
            "numeric": true,
            "override_special": "!#$%\u0026()*+_-=[]{}\u003c\u003e:?",
            "result": ":_rv}=x1k\u003c%7xOTeTjEDSkJy",
            "special": true,
            "upper": true
          },
          "sensitive_attributes": []
        }
      ]
    }
```

> bcrypt_hash (String, Sensitive) A bcrypt hash of the generated random string. NOTE: If the generated random string is greater than 72 bytes in length, bcrypt_hash will contain a hash of the first 72 bytes.

> result (String, Sensitive) The generated random string.

password本体なので当然センシティブな値が入っている。  
https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password#read-only

---

ということでremote stateにセンシティブなデータが入ることになるので、暗号化が必要。
S3　backendはencryptをサポートしているので、これを使うのが良さそう。

> The S3 backend supports encryption at rest when the encrypt option is enabled. IAM policies and logging can be used to identify any invalid access. Requests for the state go over a TLS connection.

https://developer.hashicorp.com/terraform/language/state/sensitive-data

## 3. driftの確認

手動でgrantを変更して、terraform planを実行してみる。

```sql
mysql> SHOW GRANTS FOR ruanb;
+---------------------------------------------------+
| Grants for ruanb@%                                |
+---------------------------------------------------+
| GRANT USAGE ON *.* TO `ruanb`@`%`                 |
| GRANT SELECT, UPDATE ON `foobar`.* TO `ruanb`@`%` |
+---------------------------------------------------+
2 rows in set (0.00 sec)

mysql> GRANT DELETE ON `foobar`.* TO `ruanb`;
Query OK, 0 rows affected (0.01 sec)

mysql> SHOW GRANTS FOR ruanb;
+-----------------------------------------------------------+
| Grants for ruanb@%                                        |
+-----------------------------------------------------------+
| GRANT USAGE ON *.* TO `ruanb`@`%`                         |
| GRANT SELECT, UPDATE, DELETE ON `foobar`.* TO `ruanb`@`%` |
+-----------------------------------------------------------+
2 rows in set (0.00 sec)

``` 

すでにtable指定のgrantがあるので、terraform planで差分が出る。

```shell
❯ tf plan
mysql_database.user_db: Refreshing state... [id=foobar]
random_password.user_password: Refreshing state... [id=none]
mysql_user.user_id: Refreshing state... [id=ruanb@%]
mysql_grant.user_id: Refreshing state... [id=ruanb@%:`foobar`]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # mysql_grant.user_id will be updated in-place
  ~ resource "mysql_grant" "user_id" {
        id         = "ruanb@%:`foobar`"
      ~ privileges = [
          - "DELETE",
            # (2 unchanged elements hidden)
        ]
        # (7 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.

```

Applyして相殺してみる。

```
Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

```sql
mysql> SHOW GRANTS FOR ruanb;
+---------------------------------------------------+
| Grants for ruanb@%                                |
+---------------------------------------------------+
| GRANT USAGE ON *.* TO `ruanb`@`%`                 |
| GRANT SELECT, UPDATE ON `foobar`.* TO `ruanb`@`%` |
+---------------------------------------------------+
2 rows in set (0.00 sec)

```

table指定がない、つまりそもそも定義のないgrantをいじるとどうなるか。

```sql
mysql> SHOW GRANTS FOR ruanb;
+---------------------------------------------------+
| Grants for ruanb@%                                |
+---------------------------------------------------+
| GRANT USAGE ON *.* TO `ruanb`@`%`                 |
| GRANT SELECT, UPDATE ON `foobar`.* TO `ruanb`@`%` |
+---------------------------------------------------+
2 rows in set (0.00 sec)

mysql> GRANT SELECT ON *.* TO `ruanb`;
Query OK, 0 rows affected (0.01 sec)

mysql> SHOW GRANTS FOR ruanb;
+---------------------------------------------------+
| Grants for ruanb@%                                |
+---------------------------------------------------+
| GRANT SELECT ON *.* TO `ruanb`@`%`                |
| GRANT SELECT, UPDATE ON `foobar`.* TO `ruanb`@`%` |
+---------------------------------------------------+
2 rows in set (0.00 sec)

mysql>
```

何も出ない。それはそう。

```shell
❯ tf plan
mysql_database.user_db: Refreshing state... [id=foobar]
random_password.user_password: Refreshing state... [id=none]
mysql_user.user_id: Refreshing state... [id=ruanb@%]
mysql_grant.user_id: Refreshing state... [id=ruanb@%:`foobar`]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

```

このあとimportを試すので、それができるならそれほど困ることはなさそう。

## 4. import

user, grantそれぞれのimportを試す。

```sql
mysql> CREATE USER hoge IDENTIFIED BY 'hogehoge';
Query OK, 0 rows affected (0.01 sec)

mysql> GRANT SELECT ON `foobar`.* TO `hoge`;
Query OK, 0 rows affected (0.01 sec)

mysql> SHOW GRANTS FOR hoge;
+------------------------------------------+
| Grants for hoge@%                        |
+------------------------------------------+
| GRANT USAGE ON *.* TO `hoge`@`%`         |
| GRANT SELECT ON `foobar`.* TO `hoge`@`%` |
+------------------------------------------+
2 rows in set (0.00 sec)

mysql>
```

### user

import対応している。  
https://registry.terraform.io/providers/petoju/mysql/latest/docs/resources/user#import

```hcl
import {
  to = mysql_user.user_hoge
  id = "hoge@%"
}

resource "mysql_user" "user_hoge" {
  provider = mysql.local
  user     = "hoge"
  host     = "%"
}
```

```shell
❯ tf plan
random_password.user_password: Refreshing state... [id=none]
mysql_user.user_hoge: Preparing import... [id=hoge@%]
mysql_database.user_db: Refreshing state... [id=foobar]
mysql_user.user_id: Refreshing state... [id=ruanb@%]
mysql_user.user_hoge: Refreshing state... [id=hoge@%]
mysql_grant.user_id: Refreshing state... [id=ruanb@%:`foobar`]

Terraform will perform the following actions:

  # mysql_user.user_hoge will be imported
    resource "mysql_user" "user_hoge" {
        auth_plugin        = "caching_sha2_password"
        auth_string_hashed = (sensitive value)
        host               = "%"
        id                 = "hoge@%"
        tls_option         = "NONE"
        user               = "hoge"
    }

Plan: 1 to import, 0 to add, 0 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.

❯ tf apply -auto-approve
mysql_user.user_hoge: Preparing import... [id=hoge@%]
mysql_database.user_db: Refreshing state... [id=foobar]
random_password.user_password: Refreshing state... [id=none]
mysql_user.user_hoge: Refreshing state... [id=hoge@%]
mysql_user.user_id: Refreshing state... [id=ruanb@%]
mysql_grant.user_id: Refreshing state... [id=ruanb@%:`foobar`]

Terraform will perform the following actions:

  # mysql_user.user_hoge will be imported
    resource "mysql_user" "user_hoge" {
        auth_plugin        = "caching_sha2_password"
        auth_string_hashed = (sensitive value)
        host               = "%"
        id                 = "hoge@%"
        tls_option         = "NONE"
        user               = "hoge"
    }

Plan: 1 to import, 0 to add, 0 to change, 0 to destroy.
mysql_user.user_hoge: Importing... [id=hoge@%]
mysql_user.user_hoge: Import complete [id=hoge@%]

Apply complete! Resources: 1 imported, 0 added, 0 changed, 0 destroyed.

Outputs:

password = <sensitive>
user = "ruanb"

```

Apply成功。引き続きloginもできる。

```shell
❯ mysql -h 127.0.0.1 -u hoge -P 23306 -phogehoge
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 47
Server version: 8.0.38 MySQL Community Server - GPL

Copyright (c) 2000, 2024, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

### grant

こちらもimport対応済み。  
https://registry.terraform.io/providers/petoju/mysql/latest/docs/resources/grant#import

importのkeyには

```
ユーザー名@ホスト@データベース名@テーブル名
```

の形式で指定する。

```hcl
import {
  to = mysql_grant.user_hoge
  id = "hoge@%@foobar@*"

}

resource "mysql_grant" "user_hoge" {
  provider   = mysql.local
  user       = "hoge"
  host       = "%"
  database   = var.database_name
  privileges = ["SELECT"]
}
```

```shell
❯ tf plan
mysql_grant.user_hoge: Preparing import... [id=hoge@%@foobar@*]
mysql_database.user_db: Refreshing state... [id=foobar]
mysql_user.user_hoge: Refreshing state... [id=hoge@%]
random_password.user_password: Refreshing state... [id=none]
mysql_grant.user_hoge: Refreshing state... [id=hoge@%:`foobar`]
mysql_user.user_id: Refreshing state... [id=ruanb@%]
mysql_grant.user_id: Refreshing state... [id=ruanb@%:`foobar`]

Terraform will perform the following actions:

  # mysql_grant.user_hoge will be imported
    resource "mysql_grant" "user_hoge" {
        database   = "foobar"
        grant      = false
        host       = "%"
        id         = "hoge@%:`foobar`"
        privileges = [
            "SELECT",
        ]
        roles      = []
        table      = "*"
        tls_option = "NONE"
        user       = "hoge"
    }

Plan: 1 to import, 0 to add, 0 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.

❯ tf apply -auto-approve
mysql_grant.user_hoge: Preparing import... [id=hoge@%@foobar@*]
mysql_database.user_db: Refreshing state... [id=foobar]
mysql_user.user_hoge: Refreshing state... [id=hoge@%]
random_password.user_password: Refreshing state... [id=none]
mysql_grant.user_hoge: Refreshing state... [id=hoge@%:`foobar`]
mysql_user.user_id: Refreshing state... [id=ruanb@%]
mysql_grant.user_id: Refreshing state... [id=ruanb@%:`foobar`]

Terraform will perform the following actions:

  # mysql_grant.user_hoge will be imported
    resource "mysql_grant" "user_hoge" {
        database   = "foobar"
        grant      = false
        host       = "%"
        id         = "hoge@%:`foobar`"
        privileges = [
            "SELECT",
        ]
        roles      = []
        table      = "*"
        tls_option = "NONE"
        user       = "hoge"
    }

Plan: 1 to import, 0 to add, 0 to change, 0 to destroy.
mysql_grant.user_hoge: Importing... [id=hoge@%@foobar@*]
mysql_grant.user_hoge: Import complete [id=hoge@%@foobar@*]

Apply complete! Resources: 1 imported, 0 added, 0 changed, 0 destroyed.

Outputs:

password = <sensitive>
user = "ruanb"

```

こちらもapply成功。

### password

importというか、importしたuserのpasswordを変更したい。

```diff
 resource "mysql_user" "user_hoge" {
   provider           = mysql.local
   user               = "hoge"
   host               = "%"
+  plaintext_password = random_password.hoge_password.result
 }

+ resource "random_password" "hoge_password" {
+   length           = 24
+   special          = true
+   min_special      = 2
+   override_special = "!#$%&()*+_-=[]{}<>:?"
+   keepers = {
+     password_version = var.password_version
+   }
+ }

```

```shell
❯ tf plan
mysql_database.user_db: Refreshing state... [id=foobar]
mysql_grant.user_hoge: Refreshing state... [id=hoge@%:`foobar`]
random_password.user_password: Refreshing state... [id=none]
mysql_user.user_hoge: Refreshing state... [id=hoge@%]
mysql_user.user_id: Refreshing state... [id=ruanb@%]
mysql_grant.user_id: Refreshing state... [id=ruanb@%:`foobar`]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
  ~ update in-place

Terraform will perform the following actions:

  # mysql_user.user_hoge will be updated in-place
  ~ resource "mysql_user" "user_hoge" {
        id                 = "hoge@%"
      + plaintext_password = (sensitive value)
        # (5 unchanged attributes hidden)
    }

  # random_password.hoge_password will be created
  + resource "random_password" "hoge_password" {
      + bcrypt_hash      = (sensitive value)
      + id               = (known after apply)
      + keepers          = {
          + "password_version" = "0"
        }
      + length           = 24
      + lower            = true
      + min_lower        = 0
      + min_numeric      = 0
      + min_special      = 2
      + min_upper        = 0
      + number           = true
      + numeric          = true
      + override_special = "!#$%&()*+_-=[]{}<>:?"
      + result           = (sensitive value)
      + special          = true
      + upper            = true
    }

Plan: 1 to add, 1 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.

```

Planは出る。いけるかな...?

```shell
❯ tf apply -auto-approve
mysql_database.user_db: Refreshing state... [id=foobar]
mysql_grant.user_hoge: Refreshing state... [id=hoge@%:`foobar`]
random_password.user_password: Refreshing state... [id=none]
mysql_user.user_hoge: Refreshing state... [id=hoge@%]
mysql_user.user_id: Refreshing state... [id=ruanb@%]
mysql_grant.user_id: Refreshing state... [id=ruanb@%:`foobar`]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
  ~ update in-place

Terraform will perform the following actions:

  # mysql_user.user_hoge will be updated in-place
  ~ resource "mysql_user" "user_hoge" {
        id                 = "hoge@%"
      + plaintext_password = (sensitive value)
        # (5 unchanged attributes hidden)
    }

  # random_password.hoge_password will be created
  + resource "random_password" "hoge_password" {
      + bcrypt_hash      = (sensitive value)
      + id               = (known after apply)
      + keepers          = {
          + "password_version" = "0"
        }
      + length           = 24
      + lower            = true
      + min_lower        = 0
      + min_numeric      = 0
      + min_special      = 2
      + min_upper        = 0
      + number           = true
      + numeric          = true
      + override_special = "!#$%&()*+_-=[]{}<>:?"
      + result           = (sensitive value)
      + special          = true
      + upper            = true
    }

Plan: 1 to add, 1 to change, 0 to destroy.
random_password.hoge_password: Creating...
random_password.hoge_password: Creation complete after 0s [id=none]
mysql_user.user_hoge: Modifying... [id=hoge@%]
mysql_user.user_hoge: Modifications complete after 0s [id=hoge@%]

Apply complete! Resources: 1 added, 1 changed, 0 destroyed.

Outputs:

password = <sensitive>
user = "ruanb"

```

Applyも成功。新しいpasswordをoutputさせて、loginしてみる。

```
output "password_hoge" {
  sensitive = true
  value     = random_password.hoge_password.result
}
```

```shell
❯ tf apply -auto-approve
mysql_database.user_db: Refreshing state... [id=foobar]
mysql_grant.user_hoge: Refreshing state... [id=hoge@%:`foobar`]
random_password.hoge_password: Refreshing state... [id=none]
random_password.user_password: Refreshing state... [id=none]
mysql_user.user_id: Refreshing state... [id=ruanb@%]
mysql_user.user_hoge: Refreshing state... [id=hoge@%]
mysql_grant.user_id: Refreshing state... [id=ruanb@%:`foobar`]

Changes to Outputs:
  + password_hoge = (sensitive value)

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

password = <sensitive>
password_hoge = <sensitive>
user = "ruanb"

❯ DBPASS=$(terraform output -raw password_hoge)

❯ docker exec -it mysql mysql -u hoge -p$DBPASS -e 'show databases;'
mysql: [Warning] Using a password on the command line interface can be insecure.
+--------------------+
| Database           |
+--------------------+
| foobar             |
| information_schema |
| performance_schema |
+--------------------+

❯ docker exec -it mysql mysql -u hoge -phogehoge -e 'show databases;'
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 1045 (28000): Access denied for user 'hoge'@'localhost' (using password: YES)

```

Loginできた!! 最初に手動で設定したpasswordでloginできないことも確認。  
ここまでできれば、importで困ることはなさそう。
