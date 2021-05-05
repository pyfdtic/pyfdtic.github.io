---
title: 使用 mysqldump 备份数据
date: 2018-03-19 17:47:18
categories:
- 数据库
tags:
- mysql
- mysqldump
---

## mysqldump 备份

备份数据库 my_database

    $ mysqldump -uUSER -pPASSWD my_database > my_database.sql

备份数据库 my_database 中的 my_table 表
    
    $ mysqldump -uUSER -pPASSWD my_database my_table.sql > my_table.sql

备份数据库 my_database 中的 my_table 表中 id 大于 120 的数据, where 用法
    
    $ mysqldump -uUSER -pPASSWD my_database my_table.sql --where "id > 120"> my_table.sql

备份数据库 my_database 表结构

    $ mysqldump -uUSER -pPASSWD -d my_database > my_database.sql

备份数据库 my_database 中 my_table 表(多个表)的表结构 

    $ mysqldump -uUSER -pPASSWD -d my_database my_table1 my_table2 > my_table.sql

备份多个数据库 my_database1, my_database2 

    $ mysqldump -uUSER -pPASSWD  --databases my_database1 my_database2 > my_database.sql 

备份所有数据库

    $ mysqldump -uUSER -pPASSWD --all-databases > my_database.sql

备份后压缩保存, 及还原压缩保存的数据
    
    $ mysqldump -uUSER -pPASSWD --all-databases | gzip > backupfile.sql.gz
    $ gunzip -c abc.sql.gz |mysql -uroot -proot abc     # 还原压缩的数据到数据库

在两个 mysql server 之间复制数据

    $ mysqldump --opt db_name | mysql --host=remote_host -C db_name


mysqldump 帮助
    
    --add-locks      : 在每个表导出之前增加 LOCK TABLES 并且之后 UNLOCK TABLE , 为了使得更快的插入到 Mysql
    --add-drop-table : 在每个 Create 语句之前增加一个 drop table. 
    

[参考](http://www.cnblogs.com/chenmh/p/5300370.html)