---
title: MySQL数据库RR隔离级别下的死锁问题处理
date: 2019-10-15 17:09:56
categories: 
	- 数据库
---

>  由于是在写公司需求时遇到的死锁问题，故不便透露过多信息，仅给出相关场景描述

## 场景描述

```sql
begin;
index idx_userId_value (userId, value);
select * from user_table where userId = 'u2' for update;
insert into user_table (userId, value) values ('u2', 1);
commit;
```

假设 idx_userId_value 上 userId 的顺序为 u1 u2 u3 u4

MySQL 死锁日志中记录两个事务的 insert 语句等待 gap lock，最后抛出死锁异常。

## 分析

原本的思路是可以通过互斥锁来阻塞同一个用户的并发事务。但发生了不同用户的事务，在 insert 时抛出死锁异常了。

后来发现，Gap Lock 不能阻塞除 insert 之外的所有操作(到目前为止MySQL8 是这样的)

在压测过程中有大量新账号出现了死锁，case 1

### case1

若账号 u2 和 u3 在表内无数据

事务 A：select * from user_table where userId = 'u2' for update 加锁位置为 (u1, u4)。

事务 B：select * from user_table where userId = 'u3' for update 加锁位置为 (u1, u4)

gap lock 仅阻塞 insert 操作，所以 事务 A、B 之间不会互相阻塞。

若 A 执行 insert userId 为 u2 的数据时会被阻塞，若 B 执行 insert userId 为 u3 的数据时，则会抛出死锁异常

### case 2

若账号 u2 和 u3 在表内有数据

事务 A 在 u2 和 u3 的 gap insert 的同时，事务 B 也在 u2 和 u3 的 gap insert 也会抛出死锁异常

### case3

U2 在表内无数据时，相同用户并发事务也会只加一个 Gap Lock。造成死锁

## 解决方案

### 增加死锁重试机制

出现死锁的情况比较多，条件不苛刻，会生成大量死锁日志。

### 修改隔离级别至 RC

修改成RC之后也满足不了业务需求

### 分布式锁

使用 Redisson 加分布式锁，若抢占不到分布式锁，则直接返回失败，不重试。需要将隔离级别改成RC，否则还是会出现死锁问题。具体实现需要结合业务需求。