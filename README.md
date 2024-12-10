#功能描述
编写存储过程，用于生成营销触达报告，处理和存储营销相关的数据。从多张表中提取数据，执行清理、转换、和加载操作，以生成包含详细营销信息的表格，并将其备份到历史记录表中。

#输入参数
in_data_date (类型：date)
可选参数，表示数据处理的日期。如果未指定，将使用当前系统日期 (CURRENT_DATE)。

#输出结果
返回值：integer
1 表示执行成功。
-1 表示执行失败。

#主要功能步骤

##初始化
定义变量并记录函数开始时间。

##数据处理
清空结果表。
从多个源表中提取和整合数据，插入到结果表中：
包含发送量、点击量、触达时间等信息。
过滤无效任务和测试数据。
仅处理最近 10 天的数据。

##历史备份
删除历史表 ads_report_sms_his 中与当前日期重复的数据。
将生成的报告数据备份到历史表中。

##日志记录
将函数执行的状态记录到日志表 bi_app_call_log 中，包括开始时间、结束时间、状态、和描述信息。

##返回结果
返回成功 (1) 或失败 (-1) 的状态码。
依赖的数据库表

##注意事项
依赖的序列
函数会重置序列 ads_report_sms_id_seq。

##数据过滤规则
仅处理状态为 SUCCESS 的任务。
排除创建时间早于数据日期前 10 天的数据。

##错误处理
如果执行出错，函数会返回失败状态码。

##示例用法
调用函数以指定日期处理数据：
SELECT bi_ads_report_sms('2024-12-01'::date);

调用函数处理当前日期数据：
SELECT bi_ads_report_sms(NULL);

