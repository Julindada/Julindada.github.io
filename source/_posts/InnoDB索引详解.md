---
title: InnoDB索引详解
date: 2018-12-20 14:41:21
categories: 
	- 数据库
---

> B树(Balance Tree)本质属于一颗平衡树。

> B+树是基于B树和叶子节点顺序访问指针进行实现，它具有B树的平衡性，并且通过顺序访问指针来提高区间查询的性能。

为什么使用B+树？
---
（1）B+树比起二叉树的优势

索引以索引文件的形式存储的磁盘上，每次读取节点就会进行一次磁盘IO操作，获取一个页（操作系统一般将内存和磁盘分割成固态大小的块，每一块称为一页，内存与磁盘以页为单位交换数据），而B+树“矮胖”的特点可以减少IO操作次数，以提升效率。

（2）B+树为什么比B树更合适？

1. B+树非叶子节点只包含关键字，每个磁盘块可以存储更多的关键字；而B树非叶子节点还包含数据，所以B+树中每个磁盘块可以存储更多关键字，更矮胖，IO次数更少。
2. B+树叶子节点存储全部数据，数据以指针相连形成链表；而B树非叶子节点的数据未存储在叶子节点上。所以B+树的范围查找效率比B树更高。
3. B+树查询必须查找到叶子节点，B树只要匹配到即可不用管元素位置，所以B+树查找更稳定（并不慢）。

B+树索引的分裂
---
1. 按照原页中点分裂，再将数据插入。（随机插入）
2. 分裂操作优化：不移动原页，将数据插入到新页中。（递增递减插入）

[从MySQL Bug#67718浅谈B+树索引的分裂优化](http://allan.li/mysql-index-optimize/)

B+树索引的管理
---
创建索引（联合索引）

>ALTER TABLE table_name ADD INDEX index_name (column_list1,column_list2);

>ALTER TABLE table_name ADD UNIQUE (column_list1,column_list2);

>ALTER TABLE table_name ADD PRIMARY KEY (column_list1,column_list2);

>CREATE INDEX index_name ON table_name (column_list1,column_list2);

>CREATE UNIQUE INDEX index_name ON table_name (column_list1,column_list2);

删除索引

>DROP INDEX index_name ON talbe_name;

>ALTER TABLE table_name DROP INDEX index_name;

>ALTER TABLE table_name DROP PRIMARY KEY;

查看索引

>SHOW INDEX FROM talbe_name;

>SHOW KEYS FROM talbe_name;

- Table： 表的名称
- Non_unique： 非唯一，如果索引不能包括重复词，则为0。如果可以，则为1
- Key_name： 索引名称，可以用这个名称DROP INDEX
- Seq_in_index： 索引中该列的位置（常见于联合索引）
- Column_name： 索引列的名称
- Collation： 索引存储方式。A：B+树索引，有序。NULL：Hash索引
- Cardinality： 索引中唯一值的数目的估计值
- Sub_part： 是否为列的部分被索引，若显示100，则表示只对该列的前100个字符索引。如果显示NULL，则整个列被索引
- Packed： 关键字如何被压缩
- Null： 是否为null
- Index_type： 索引的类型
- Comment： 注释

B+树索引的查询性能优化
---
（1） 使用 Explain 进行分析

[MySQL 性能优化神器 Explain 使用分析](https://segmentfault.com/a/1190000008131735)

（2）

SELECT * FROM talbe_name USE INDEX(index_name) WHERE();

USE INDEX(index_name) 建议优化器使用索引

FORCE INDEX(index_name) 强制优化器使用索引

（3）索引失效的解决方法以及索引使用的注意点

1. 一般在where和join中出现的列需要建立索引
2. MySQL只对<、<=、=、>、>=、BETWEEN、IN和部分情况下的LIKE才会使用索引
3. 查询条件包含OR，且有不含索引的列时，索引失效
4. 联合索引，不符合最左前缀原则，索引失效
5. LIKE模糊查询以%开头，索引失效
6. 列类型是字符串，WHERE时不用引号，索引失效
7. 当全表扫描速度比索引速度快时，mysql会使用全表扫描，此时索引失效

全文检索
---
全文索引(Full-Text Search)是将存储于数据库中的整本书或整篇文章中的任意内容信息查找出来的技术。

（1）倒排索引（辅助表）

- inverted file index {单词,单词所在文档的ID}
- full inverted index {单词,(单词所在的文档ID,在具体文档中的位置)}

参考资料：
---
- 《MySQL技术内幕:InnoDB存储引擎(第2版)》 姜承尧 著
- [从B树、B+树、B*树谈到R 树](https://blog.csdn.net/v_JULY_v/article/details/6530142)
- [从MySQL Bug#67718浅谈B+树索引的分裂优化](http://allan.li/mysql-index-optimize/)