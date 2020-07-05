/* 출금리스트에서 대상이 차량인 쿼리문 */

SELECT MID(t1.account_code,6,4) AS 차량번호네자리, LEFT(t1.account_code,9) AS 차량번호, t2.work_group AS 작업구분, t2.work_group_day AS 지급일, t2.company_name AS 상호명,
  t2.bank AS 은행, t2.bank_account AS 계좌번호, t2.bank_holder AS 예금주, 
  
  SUM(if(kind_item = '기타(매출)' OR kind_item = '운송료(매출)' OR kind_item = '관리비(차량)' OR kind_item = '임대료(샤시)' 
    OR kind_item = '수리비(차량)' OR kind_item = '수리비(업체)',tax_total_amount,0)) AS 계산서매출합계,
    
  SUM(if(kind_item = '운송료(매입_차량)' OR kind_item = '기타(매입)' OR kind_item = '운송료(매입_업체)' OR kind_item = '임차료(샤시)',tax_total_amount,0)) AS 계산서매입합계,  
  
  sum(if(in_out = '입금' AND (is_can_update = 'yes' or is_can_update = 'true') AND ( mstatus = '선납' OR mstatus = '완료' OR  mstatus IS null), current_money, 0)) AS 현금입금,   

  sum(if(in_out = '출금' AND (is_can_update = 'yes' OR is_can_update = 'true') AND ( mstatus = '선납' OR mstatus = '완료' OR  mstatus IS null), current_money, 0)) AS 현금출금, 
 
  
  GROUP_CONCAT(taxbill_code SEPARATOR  '/' ) AS 관련근거    	

FROM tbl_money_info AS t1
LEFT JOIN tbl_carinfo_total2 AS t2
ON t1.car_code = t2.car_code
WHERE left(action_month,7) =  left(DATE_SUB( curdate(),  INTERVAL 0  month  ) ,7) /*INTERVAL 0=당월, 1=전월 2= 전전월 */
 AND car_or_company = '차량'  /* car_or_company 기준으로 업체와 차량 구분 */
 AND out_date2 IS null
 AND unit_name IS NULL
 AND (tstatus <> '완료' OR mstatus <> '완료')
GROUP BY account_code
/* HAVING 계산서매입합계 + 현금입금 - 계산서매출합계- 현금출금 > 0  */
-- github test 용 파일
