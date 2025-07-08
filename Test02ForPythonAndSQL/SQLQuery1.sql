/*==============================================================*/
/* 仓库管理系统数据库建表脚本                                      */
/* DBMS name:      SAP SQL Anywhere 17                          */
/* Created on:     2023/6/4 22:08:09                            */
/* 系统功能: 管理仓库货物出入库、库存跟踪、供应商管理、操作员管理    */
/*==============================================================*/

-- ==============================================================
-- 第一步：删除外键约束（如果存在）
-- 目的：确保在重建表结构时不会出现外键冲突
-- ==============================================================

-- 删除仓库表的外键约束
if exists(select 1 from sys.sysforeignkey where role='FK_CANGKU_CUNFANG_KUCUN') then
    alter table cangku
       delete foreign key FK_CANGKU_CUNFANG_KUCUN
end if;

if exists(select 1 from sys.sysforeignkey where role='FK_CANGKU_GUANLI_CAOZUOYU') then
    alter table cangku
       delete foreign key FK_CANGKU_GUANLI_CAOZUOYU
end if;

-- 删除出库表的外键约束
if exists(select 1 from sys.sysforeignkey where role='FK_CHUKU_JILU_KUCUN') then
    alter table chuku
       delete foreign key FK_CHUKU_JILU_KUCUN
end if;

-- 删除供应关系表的外键约束
if exists(select 1 from sys.sysforeignkey where role='FK_GONGYING_GONGYING_GONGYING') then
    alter table gongying
       delete foreign key FK_GONGYING_GONGYING_GONGYING
end if;

if exists(select 1 from sys.sysforeignkey where role='FK_GONGYING_GONGYING2_CANGKU') then
    alter table gongying
       delete foreign key FK_GONGYING_GONGYING2_CANGKU
end if;

-- 删除库存表的外键约束
if exists(select 1 from sys.sysforeignkey where role='FK_KUCUN_CUNFANG2_CANGKU') then
    alter table kucun
       delete foreign key FK_KUCUN_CUNFANG2_CANGKU
end if;

if exists(select 1 from sys.sysforeignkey where role='FK_KUCUN_JILU1_RUKU') then
    alter table kucun
       delete foreign key FK_KUCUN_JILU1_RUKU
end if;

-- 删除入库表的外键约束
if exists(select 1 from sys.sysforeignkey where role='FK_RUKU_JILU2_KUCUN') then
    alter table ruku
       delete foreign key FK_RUKU_JILU2_KUCUN
end if;

-- ==============================================================
-- 第二步：删除索引（如果存在）
-- 目的：清理旧的索引结构，为重建做准备
-- ==============================================================

-- 删除仓库表的索引
drop index if exists cangku.guanli_FK;      -- 操作员管理索引
drop index if exists cangku.cunfang_FK;     -- 库存存放索引
drop index if exists cangku.cangku_PK;      -- 仓库主键索引

-- 删除操作员表的索引
drop index if exists caozuoyuan.caozuoyuan_PK;  -- 操作员主键索引

-- 删除出库表的索引
drop index if exists chuku.jilu_FK;         -- 库存记录索引
drop index if exists chuku.chuku_PK;        -- 出库主键索引

-- 删除供应关系表的索引
drop index if exists gongying.gongying2_FK; -- 仓库关联索引
drop index if exists gongying.gongying_FK;  -- 供应商关联索引
drop index if exists gongying.gongying_PK;  -- 供应关系主键索引

-- 删除供应商表的索引
drop index if exists gongyingshang.gongyingshang_PK;  -- 供应商主键索引

-- 删除库存表的索引
drop index if exists kucun.jilu1_FK;        -- 入库记录索引
drop index if exists kucun.cunfang2_FK;     -- 仓库存放索引
drop index if exists kucun.kucun_PK;        -- 库存主键索引

-- 删除入库表的索引
drop index if exists ruku.jilu2_FK;         -- 库存记录索引
drop index if exists ruku.ruku_PK;          -- 入库主键索引

-- ==============================================================
-- 第三步：删除表（如果存在）
-- 目的：清理旧的表结构，确保可以重新创建
-- ==============================================================

drop table if exists cangku;        -- 仓库表
drop table if exists caozuoyuan;    -- 操作员表
drop table if exists chuku;         -- 出库表
drop table if exists gongying;      -- 供应关系表
drop table if exists gongyingshang; -- 供应商表
drop table if exists kucun;         -- 库存表
drop table if exists ruku;          -- 入库表

-- ==============================================================
-- 第四步：创建表结构
-- 目的：建立完整的仓库管理系统数据库结构
-- ==============================================================

/*==============================================================*/
/* 表名: cangku (仓库表)                                         */
/* 功能: 存储仓库的基本信息，包括仓库名称、负责人、创建日期等        */
/* 业务意义: 作为仓库管理的核心实体，关联库存和操作员信息          */
/*==============================================================*/
create table cangku 
(
   cangkumingcheng      varchar(20)                    not null,  -- 仓库名称（主键）
   xingming             varchar(20)                    null,      -- 操作员姓名（关联操作员表）
   bianhao              varchar(20)                    null,      -- 库存编号（关联库存表）
   cangkufuzeren        varchar(20)                    null,      -- 仓库负责人
   cangkuchuangjianriqi varchar(20)                    null,      -- 仓库创建日期
   constraint PK_CANGKU primary key clustered (cangkumingcheng)   -- 主键约束
);

/*==============================================================*/
/* 索引: cangku_PK (仓库主键索引)                                */
/* 目的: 优化按仓库名称查询的性能                                */
/*==============================================================*/
create unique clustered index cangku_PK on cangku (
cangkumingcheng ASC
);

/*==============================================================*/
/* 索引: cunfang_FK (库存存放索引)                               */
/* 目的: 优化库存与仓库关联查询的性能                            */
/*==============================================================*/
create index cunfang_FK on cangku (
bianhao ASC
);

/*==============================================================*/
/* 索引: guanli_FK (操作员管理索引)                              */
/* 目的: 优化操作员与仓库关联查询的性能                          */
/*==============================================================*/
create index guanli_FK on cangku (
xingming ASC
);

/*==============================================================*/
/* 表名: caozuoyuan (操作员表)                                   */
/* 功能: 存储系统操作员的基本信息                                */
/* 业务意义: 管理系统用户，控制操作权限                          */
/*==============================================================*/
create  table caozuoyuan 
(
   xingming             varchar(20)                    not null,  -- 操作员姓名（主键）
   caozuoyuanlianxifangshi varchar(20)                    null,      -- 操作员联系方式
   constraint PK_CAOZUOYUAN primary key clustered (xingming)      -- 主键约束
);

/*==============================================================*/
/* 索引: caozuoyuan_PK (操作员主键索引)                          */
/* 目的: 优化按操作员姓名查询的性能                              */
/*==============================================================*/
create unique clustered index caozuoyuan_PK on caozuoyuan (
xingming ASC
);

/*==============================================================*/
/* 表名: chuku (出库表)                                          */
/* 功能: 记录货物出库的详细信息                                  */
/* 业务意义: 跟踪货物出库流程，维护库存准确性                      */
/*==============================================================*/
create  table chuku 
(
   chukubianhao         varchar(20)                    not null,  -- 出库编号（主键）
   bianhao              varchar(20)                    null,      -- 库存编号（关联库存表）
   huowubianhao         varchar(20)                    null,      -- 货物编号
   shuliang             varchar(20)                    null,      -- 出库数量
   mingcheng            varchar(20)                    null,      -- 货物名称
   chukuriqi            varchar(20)                    null,      -- 出库日期
   danjia               varchar(20)                    null,      -- 出库单价
   constraint PK_CHUKU primary key clustered (chukubianhao)      -- 主键约束
);

/*==============================================================*/
/* 索引: chuku_PK (出库主键索引)                                  */
/* 目的: 优化按出库编号查询的性能                                */
/*==============================================================*/
create unique clustered index chuku_PK on chuku (
chukubianhao ASC
);

/*==============================================================*/
/* 索引: jilu_FK (库存记录索引)                                   */
/* 目的: 优化出库与库存关联查询的性能                            */
/*==============================================================*/
create index jilu_FK on chuku (
bianhao ASC
);

/*==============================================================*/
/* 表名: gongying (供应关系表)                                    */
/* 功能: 管理供应商与仓库之间的供应关系                          */
/* 业务意义: 建立供应商与仓库的多对多关系                        */
/*==============================================================*/
create  table gongying 
(
   gongyingshangbianhao varchar(20)                    not null,  -- 供应商编号（复合主键）
   cangkumingcheng      varchar(20)                    not null,  -- 仓库名称（复合主键）
   constraint PK_GONGYING primary key clustered (gongyingshangbianhao, cangkumingcheng)  -- 复合主键约束
);

/*==============================================================*/
/* 索引: gongying_PK (供应关系主键索引)                           */
/* 目的: 优化供应关系查询的性能                                  */
/*==============================================================*/
create unique clustered index gongying_PK on gongying (
gongyingshangbianhao ASC,
cangkumingcheng ASC
);

/*==============================================================*/
/* 索引: gongying_FK (供应商关联索引)                             */
/* 目的: 优化供应商与供应关系关联查询的性能                      */
/*==============================================================*/
create index gongying_FK on gongying (
gongyingshangbianhao ASC
);

/*==============================================================*/
/* 索引: gongying2_FK (仓库关联索引)                              */
/* 目的: 优化仓库与供应关系关联查询的性能                        */
/*==============================================================*/
create index gongying2_FK on gongying (
cangkumingcheng ASC
);

/*==============================================================*/
/* 表名: gongyingshang (供应商表)                                 */
/* 功能: 存储供应商的基本信息                                    */
/* 业务意义: 管理货物供应商，支持采购流程                        */
/*==============================================================*/
create  table gongyingshang 
(
   gongyingshangbianhao varchar(20)                    not null,  -- 供应商编号（主键）
   gongyingshangmingcheng varchar(20)                    null,      -- 供应商名称
   lianxirren           varchar(20)                    null,      -- 联系人
   lianxifangshi        varchar(20)                    null,      -- 联系方式
   constraint PK_GONGYINGSHANG primary key clustered (gongyingshangbianhao)  -- 主键约束
);

/*==============================================================*/
/* 索引: gongyingshang_PK (供应商主键索引)                        */
/* 目的: 优化按供应商编号查询的性能                              */
/*==============================================================*/
create unique clustered index gongyingshang_PK on gongyingshang (
gongyingshangbianhao ASC
);

/*==============================================================*/
/* 表名: kucun (库存表)                                          */
/* 功能: 记录当前各仓库的货物库存状态                            */
/* 业务意义: 核心业务表，实时反映库存情况                        */
/*==============================================================*/
create  table kucun 
(
   bianhao              varchar(20)                    not null,  -- 库存编号（主键）
   rukubianhao          varchar(20)                    null,      -- 入库编号（关联入库表）
   cangkumingcheng      varchar(20)                    null,      -- 仓库名称（关联仓库表）
   shuliang             varchar(20)                    null,      -- 库存数量
   danjia               varchar(20)                    null,      -- 库存单价
   constraint PK_KUCUN primary key clustered (bianhao)           -- 主键约束
);

/*==============================================================*/
/* 索引: kucun_PK (库存主键索引)                                  */
/* 目的: 优化按库存编号查询的性能                                */
/*==============================================================*/
create unique clustered index kucun_PK on kucun (
bianhao ASC
);

/*==============================================================*/
/* 索引: cunfang2_FK (仓库存放索引)                               */
/* 目的: 优化库存与仓库关联查询的性能                            */
/*==============================================================*/
create index cunfang2_FK on kucun (
cangkumingcheng ASC
);

/*==============================================================*/
/* 索引: jilu1_FK (入库记录索引)                                  */
/* 目的: 优化库存与入库关联查询的性能                            */
/*==============================================================*/
create index jilu1_FK on kucun (
rukubianhao ASC
);

/*==============================================================*/
/* 表名: ruku (入库表)                                           */
/* 功能: 记录货物入库的详细信息                                  */
/* 业务意义: 跟踪货物入库流程，更新库存信息                      */
/*==============================================================*/
create  table ruku 
(
   danjia               varchar(20)                    null,      -- 入库单价
   rukubianhao          varchar(20)                    not null,  -- 入库编号（主键）
   bianhao              varchar(20)                    null,      -- 库存编号（关联库存表）
   huowubianhao         varchar(20)                    null,      -- 货物编号
   shuliang             varchar(20)                    null,      -- 入库数量
   mingcheng            varchar(20)                    null,      -- 货物名称
   rukuriqi             varchar(20)                    null,      -- 入库日期
   gongyingshangmingcheng varchar(20)                    null,      -- 供应商名称
   constraint PK_RUKU primary key clustered (rukubianhao)        -- 主键约束
);

/*==============================================================*/
/* 索引: ruku_PK (入库主键索引)                                   */
/* 目的: 优化按入库编号查询的性能                                */
/*==============================================================*/
create unique clustered index ruku_PK on ruku (
rukubianhao ASC
);

/*==============================================================*/
/* 索引: jilu2_FK (库存记录索引)                                  */
/* 目的: 优化入库与库存关联查询的性能                            */
/*==============================================================*/
create index jilu2_FK on ruku (
bianhao ASC
);

-- ==============================================================
-- 第五步：建立外键约束关系
-- 目的：确保数据完整性和一致性，建立表之间的业务关联
-- ==============================================================

-- 仓库表与库存表的外键关系：仓库通过编号关联库存记录
-- 业务含义：每个库存记录必须对应一个有效的仓库
alter table cangku
   add constraint FK_CANGKU_CUNFANG_KUCUN foreign key (bianhao)
      references kucun (bianhao)
      on update restrict
      on delete restrict;

-- 仓库表与操作员表的外键关系：仓库通过姓名关联操作员
-- 业务含义：每个仓库必须有一个负责的操作员
alter table cangku
   add constraint FK_CANGKU_GUANLI_CAOZUOYU foreign key (xingming)
      references caozuoyuan (xingming)
      on update restrict
      on delete restrict;

-- 出库表与库存表的外键关系：出库记录关联库存编号
-- 业务含义：每次出库必须基于现有的库存记录
alter table chuku
   add constraint FK_CHUKU_JILU_KUCUN foreign key (bianhao)
      references kucun (bianhao)
      on update restrict
      on delete restrict;

-- 供应关系表与供应商表的外键关系：供应关系关联供应商信息
-- 业务含义：每个供应关系必须对应一个有效的供应商
alter table gongying
   add constraint FK_GONGYING_GONGYING_GONGYING foreign key (gongyingshangbianhao)
      references gongyingshang (gongyingshangbianhao)
      on update restrict
      on delete restrict;

-- 供应关系表与仓库表的外键关系：供应关系关联仓库信息
-- 业务含义：每个供应关系必须对应一个有效的仓库
alter table gongying
   add constraint FK_GONGYING_GONGYING2_CANGKU foreign key (cangkumingcheng)
      references cangku (cangkumingcheng)
      on update restrict
      on delete restrict;

-- 库存表与仓库表的外键关系：库存通过仓库名称关联仓库
-- 业务含义：每个库存记录必须存放在一个有效的仓库中
alter table kucun
   add constraint FK_KUCUN_CUNFANG2_CANGKU foreign key (cangkumingcheng)
      references cangku (cangkumingcheng)
      on update restrict
      on delete restrict;

-- 库存表与入库表的外键关系：库存通过入库编号关联入库记录
-- 业务含义：每个库存记录必须对应一个入库记录
alter table kucun
   add constraint FK_KUCUN_JILU1_RUKU foreign key (rukubianhao)
      references ruku (rukubianhao)
      on update restrict
      on delete restrict;

-- 入库表与库存表的外键关系：入库记录关联库存编号
-- 业务含义：每次入库都会影响对应的库存记录
alter table ruku
   add constraint FK_RUKU_JILU2_KUCUN foreign key (bianhao)
      references kucun (bianhao)
      on update restrict
      on delete restrict;

-- ==============================================================
-- 数据库建表脚本执行完成
-- 系统功能说明：
-- 1. 支持多仓库管理
-- 2. 完整的出入库流程跟踪
-- 3. 实时库存状态管理
-- 4. 供应商信息管理
-- 5. 操作员权限控制
-- 6. 数据完整性保证
-- ==============================================================

