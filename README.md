# terraform-provider-mysql-play-petoju

https://ruan.dev/blog/2023/07/15/how-to-use-the-mysql-terraform-provider を動かしてみる。

## 1. 一通り動かす

書いてあるとおりapplyしてdatabase, userを作ってログインしてみる。
passwordのrotateが簡単にできるのは便利。

```
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

```
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
