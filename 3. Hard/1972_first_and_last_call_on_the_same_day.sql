Table: Calls

+--------------+----------+
| Column Name  | Type     |
+--------------+----------+
| caller_id    | int      |
| recipient_id | int      |
| call_time    | datetime |
+--------------+----------+
(caller_id, recipient_id, call_time) is the primary key for this table.
Each row contains information about the time of a phone call between caller_id and recipient_id.
 

Write an SQL query to report the IDs of the users whose first and last calls on any day were with the same person. Calls are counted regardless of being the caller or the recipient.

Return the result table in any order.

The query result format is in the following example.



Example 1:

Input: 
Calls table:
+-----------+--------------+---------------------+
| caller_id | recipient_id | call_time           |
+-----------+--------------+---------------------+
| 8         | 4            | 2021-08-24 17:46:07 |
| 4         | 8            | 2021-08-24 19:57:13 |
| 5         | 1            | 2021-08-11 05:28:44 |
| 8         | 3            | 2021-08-17 04:04:15 |
| 11        | 3            | 2021-08-17 13:07:00 |
| 8         | 11           | 2021-08-17 22:22:22 |
+-----------+--------------+---------------------+
Output: 
+---------+
| user_id |
+---------+
| 1       |
| 4       |
| 5       |
| 8       |
+---------+
Explanation: 
On 2021-08-24, the first and last call of this day for user 8 was with user 4. User 8 should be included in the answer.
Similarly, user 4 on 2021-08-24 had their first and last call with user 8. User 4 should be included in the answer.
On 2021-08-11, user 1 and 5 had a call. This call was the only call for both of them on this day. Since this call is the first and last call of the day for both of them, they should both be included in the answer.


-- My Answer
With IntegratedCalls AS 
(SELECT * 
FROM Calls C 
UNION 
SELECT recipient_id caller_id, caller_id recipient_id, call_time
FROM Calls C), 
MinMaxCalls AS 
(SELECT caller_id, DATE(call_time) call_date, MIN(call_time) OVER (PARTITION BY caller_id, DATE(call_time)) min_date, MAX(call_time) OVER (PARTITION BY caller_id, DATE(call_time)) max_date, recipient_id, call_time 
FROM IntegratedCalls IC),
MinMaxLabels AS 
(SELECT MMC.*, CASE WHEN min_date=max_date THEN "same" WHEN call_time = min_date THEN "min" WHEN call_time = max_date THEN 'max'  END max_min_caller
FROM MinMaxCalls MMC)


SELECT MML1.caller_id user_id 
FROM MinMaxLabels MML1, MinMaxLabels MML2 
WHERE MML1.caller_id = MML2.caller_id 
AND MML1.max_min_caller= 'min'
AND MML2.max_min_caller='max'
AND MML1.recipient_id = MML2.recipient_id
UNION 
SELECT MML1.caller_id user_id 
FROM MinMaxLabels MML1
WHERE 1=1 
AND MML1.max_min_caller= 'same'


-- What I learned 
1) You have to be careful when using CASE clause. Some conditions might never be triggered if placed behind. 
2) If you have to compare both min and max values at once, you should probably use PARTITION BY then GROUP BY. 