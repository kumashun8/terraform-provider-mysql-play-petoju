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
