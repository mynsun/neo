SELECT 'successe' FROM dual;

SELECT count(*) FROM  HR."BIGEMPLOYEES" be;

CREATE USER "USER1" IDENTIFIED BY "1234";

ALTER USER "USER1" account unlock;

GRANT CREATE SESSION TO "USER1";

GRANT ALL ON SHOP.membertbl TO "USER1";

GRANT ALL ON SHOP.producttbl TO "USER1";

GRANT SELECT ON HR.BIGEMPLOYEES TO "USER1";

select * from hr.bigemployees;

CREATE USER "DIRECTOR" IDENTIFIED BY "1234";

ALTER USER "DIRECTOR" account unlock;

GRANT CREATE SESSION TO "DIRECTOR";

GRANT ALL ON SHOP.membertbl TO "DIRECTOR";

GRANT ALL ON SHOP.producttbl TO "DIRECTOR";

GRANT SELECT ON HR.BIGEMPLOYEES TO "DIRECTOR";

SELECT * FROM hr.usertbl;

SELECT * FROM hr.buytbl;

CREATE TABLE buytbl2 AS (SELECT * FROM buytbl);

SELECT * FROM buytbl2;

CREATE TABLE buytbl3 AS (SELECT userid, prodname FROM buytbl);

SELECT * FROM buytbl3;

SELECT userid AS "사용자", sum(amount) AS "총구매량"
FROM buytbl GROUP BY userid;

SELECT cast(avg(amount) AS number(5,3)) AS "평균 구매 수량"
FROM buytbl;

SELECT cast(avg(amount) AS number(5,3)) AS "평균 구매 수량"
FROM buytbl GROUP BY userid;

SELECT username, max(height), min(height)
FROM usertbl GROUP BY username;

SELECT username, height FROM usertbl
WHERE height = (SELECT max(height) FROM usertbl)
OR height = (SELECT min(height) FROM usertbl);

SELECT count(*) FROM usertbl;

SELECT count(mobile1) AS "휴대폰소유자" FROM usertbl;

SELECT userid AS "사용자", sum(amount * price) AS "총구매액"
FROM buytbl GROUP BY userid;

SELECT userid AS "사용자명", sum(amount * price) AS "총구매액"
FROM buytbl GROUP BY userid
HAVING sum(price * amount) > 1000
ORDER BY sum(price * amount);

SELECT idnum, groupname, sum(price * amount)
AS "비용"
FROM buytbl
GROUP BY rollup(groupname, idnum);

SELECT groupname, sum(price * amount)
AS "비용"
FROM buytbl
GROUP BY rollup(groupname);

SELECT groupname, sum(price * amount)
AS "비용",
GROUPING_ID(groupname) AS "추가행 여부"
FROM buytbl
GROUP BY rollup(groupname);

CREATE TABLE cubetbl(prodname nchar(3), color nchar(2), amount int);

INSERT INTO cubetbl values('컴퓨터','검정', 11);

INSERT INTO cubetbl values('컴퓨터','파랑', 22);

INSERT INTO cubetbl values('컴퓨터','검정', 33);

INSERT INTO cubetbl values('컴퓨터','파랑', 44);

SELECT * FROM cubetbl;

SELECT prodname, color, sum(amount) AS "수량 합계"
FROM cubetbl
GROUP BY cube(color, prodname)
ORDER BY prodname, color;

CREATE TABLE emptbl (emp nchar(3), manager nchar(3), department nchar(3));

INSERT INTO emptbl VALUES ('나사장', '없음', '없음');
INSERT INTO emptbl VALUES ('김재무', '나사장', '재무부');
INSERT INTO emptbl VALUES ('김부장', '김재무', '재무부');
INSERT INTO emptbl VALUES ('이부장', '김재무', '재무부');
INSERT INTO emptbl VALUES ('우대리', '이부장', '재무부');
INSERT INTO emptbl VALUES ('지사원', '이부장', '재무부');
INSERT INTO emptbl VALUES ('이영업', '나사장', '영업부');
INSERT INTO emptbl VALUES ('한과장', '이영업', '영업부');
INSERT INTO emptbl VALUES ('최정보', '나사장', '정보부');
INSERT INTO emptbl values ('윤차장', '최정보', '정보부');
INSERT INTO emptbl values ('이주임', '윤차장', '정보부');

SELECT * FROM emptbl;

WITH empcte(empname, mgrname, dept, emplevel)
AS
(
	(SELECT emp, manager, department, 0
	FROM emptbl
	WHERE manager='없음')
	UNION ALL
	(SELECT emptbl.emp, emptbl.manager,
	emptbl.department, empcte.emplevel+1
	FROM emptbl INNER JOIN empcte
	ON emptbl.manager = empcte.empname)
)
SELECT * FROM empcte ORDER BY dept,emplevel;

WITH empcte(empname, mgrname, dept, emplevel)
AS
(
	(SELECT emp, manager, department, 0
	FROM emptbl
	WHERE manager='없음')
	UNION ALL
	(SELECT emptbl.emp, emptbl.manager,
	emptbl.department, empcte.emplevel+1
	FROM emptbl INNER JOIN empcte
	ON emptbl.manager = empcte.empname)
)
SELECT CONCAT(rpad('ㄴ', emplevel * 2 + 1 , 'ㄴ'),
empname) AS "직원이름",
dept AS "직원부서"
FROM empcte ORDER BY dept, emplevel;

WITH empcte(empname, mgrname, dept, emplevel)
AS
(
	(SELECT emp, manager, department, 0
	FROM emptbl
	WHERE manager='없음')
	UNION ALL
	(SELECT emptbl.emp, emptbl.manager,
	emptbl.department, empcte.emplevel+1
	FROM emptbl INNER JOIN empcte
	ON emptbl.manager = empcte.empname)
)
SELECT CONCAT(rpad('ㄴ', emplevel * 2 + 1 , 'ㄴ'),
empname) AS "직원이름",
dept AS "직원부서"
FROM empcte ORDER BY dept, emplevel;

WITH empcte(empname, mgrname, dept, emplevel)
AS
(
	(SELECT emp, manager, department, 0
	FROM emptbl
	WHERE manager='없음')
	UNION ALL
	(SELECT emptbl.emp, emptbl.manager,
	emptbl.department, empcte.emplevel+1
	FROM emptbl INNER JOIN empcte
	ON emptbl.manager = empcte.empname
	WHERE emplevel < 2 )
)
SELECT CONCAT(rpad('ㄴ', emplevel * 2 + 1 , 'ㄴ'),
empname) AS "직원이름",
dept AS "직원부서"
FROM empcte ORDER BY dept, emplevel;

CREATE TABLE testtbl1 (id NUMBER(4), username nchar(3), age number(2));

INSERT INTO testtbl1 values(1,'홍길동',25);

SELECT * FROM testtbl1;

INSERT INTO testtbl1 (id,username) VALUES (2,'설현');

SELECT * FROM testtbl1;

INSERT INTO testtbl1 (username, id, age) VALUES ('지민', 3, 26);

SELECT * FROM testtbl1;

-- Error

INSERT INTO testtbl1 values(4,36, '공유');

CREATE TABLE testtbl2 (	
	id number(4),
	usename nchar(3),
	age number(2),
	nation nchar(4) DEFAULT '대한민국'
);

CREATE SEQUENCE idseq2
start WITH 1
INCREMENT BY 1;

INSERT INTO TESTTBL2 VALUES (idseq2.nextval, '유나', 25, default);

SELECT * FROM testtbl2;

INSERT INTO testtbl2 VALUES (11, '쯔위', 18, '대만');

SELECT * FROM testtbl2;

ALTER SEQUENCE idseq2
INCREMENT BY 10;

INSERT INTO testtbl2 VALUES (idseq2.nextval, '미나', 21,'일본');

SELECT * FROM testtbl2;

ALTER SEQUENCE idseq2
INCREMENT BY 1;

INSERT INTO testtbl2 VALUES (idseq2.nextval,'사나', 21,'일본');

SELECT * FROM testtbl2;

ALTER SEQUENCE idseq2
INCREMENT BY 5;

INSERT INTO testtbl2 VALUES (idseq2.nextval, '채영', 23,default);

SELECT * FROM testtbl2;

SELECT idseq2.currval FROM testtbl2;

--
CREATE TABLE testtbl3 (id NUMBER(3));

CREATE SEQUENCE cycleseq
START WITH 100
INCREMENT BY 100
MINVALUE 100
MAXVALUE 300
CYCLE
nocache;

INSERT INTO testtbl3 VALUES (cycleseq.nextval);

INSERT INTO testtbl3 VALUES (cycleseq.nextval);

INSERT INTO testtbl3 VALUES (cycleseq.nextval);

INSERT INTO testtbl3 VALUES (cycleseq.nextval);

SELECT * FROM testtbl3;

--
CREATE TABLE testtbl4(
	empid number(6),
	firstname varchar2(20),
	lastname varchar2(25),
	phone varchar2(20)
);

INSERT INTO testtbl4
	SELECT EMPLOYEE_id, first_name, last_name, phone_number
	FROM employees;

SELECT * FROM testtbl4;

-- Update Query

UPDATE testtbl4
	SET firstname='David'
	WHERE empid=100;

SELECT * FROM testtbl4
WHERE empid=100;

-- Delete Query

SELECT * FROM testtbl4 WHERE lastname='King';

-- commit

COMMIT;

DELETE FROM testtbl4
WHERE firstname='David' AND lastname='King';

-- rollback
ROLLBACK;

SELECT * FROM testtbl4 WHERE lastname='King';

CREATE TABLE bigtbl1
AS
	SELECT LEVEL AS bigid,
	round(dbms_random.value(1,500000), 0)
AS numdata
	FROM dual
	CONNECT BY LEVEL <= 500000;

CREATE TABLE bigtbl2
AS
	SELECT LEVEL AS bigid,
	round(dbms_random.value(1,500000), 0)
AS numdata
	FROM dual
	CONNECT BY LEVEL <= 500000;

CREATE TABLE bigtbl3
AS
	SELECT LEVEL AS bigid,
	round(dbms_random.value(1,500000), 0)
AS numdata
	FROM dual
	CONNECT BY LEVEL <= 500000;

delete from bigtbl1;

commit;

DROP TABLE bigtbl2;

truncate TABLE bigtbl3;

DROP TABLE bigtbl1;

DROP TABLE bigtbl3;


--

CREATE TABLE member1
AS (SELECT userid, username, addr FROM usertbl);

SELECT * FROM member1;

CREATE TABLE changetbl (
	userid char(8),
	username nvarchar2(10),
	addr nchar(2),
	changetype nchar(4)
);

INSERT INTO changetbl values('TKV', '태권브이','한국','신규가입');
INSERT INTO changetbl values('LGG', NULL,'제주','주소변경');
INSERT INTO changetbl values('LJB', NULL,'한국','주소변경');
INSERT INTO changetbl values('BBK', NULL,'탈퇴','회원탈퇴');
INSERT INTO changetbl values('SSK', NULL,'탈퇴','회원탈퇴');

SELECT * FROM member1;

MERGE INTO member1 M
USING (SELECT changetype, userid, username, addr FROM changetbl) C
ON (M.userid = C.userid)
WHEN MATCHED THEN 
	UPDATE SET M.addr = C.addr
	DELETE WHERE C.changetype = '회원탈퇴'
WHEN NOT MATCHED THEN
	INSERT (userid, username, addr) VALUES
	(C.userid, C.username, C.addr);

SELECT * FROM changetbl;

SELECT * FROM usertbl;

SELECT * FROM member1;

select avg(amount) from buytbl;

select cast(avg(amount) as number(3)) from buytbl;

select cast(avg(amount) as number(3,5)) from buytbl;

select cast('2025$3$21' as date) from dual;

select cast(price as char(5)) || 'X' || cast(amount as char(4)) || '==' as "단가 X 수량",
price * amount as "구매액"
from buytbl;

select to_char(1234, '$999,999') from dual;

select to_char(12345, '$000,999') from dual;

select to_char(12345, 'L999,999') from dual;

select to_char(sysdate, 'yy/mm/dd hh:mm:ss') from dual;

select to_char(10,'X'), to_char(255,'XX') from dual;

select to_number('0123'), to_number('1234.456') from dual;

--

SELECT '100' + '200' FROM dual;

SELECT concat('100','200') FROM dual;

SELECT 100 || '200' FROM dual;

SELECT price FROM buytbl WHERE price >='500';

SELECT ascii('A'), chr(65), asciistr('한'), unistr('\D55C') FROM dual;

SELECT length('한글'), length('AB'), lengthb('한글'), lengthb('AB') FROM dual;

SELECT concat('이것이', 'ORACLE이다'), '이것이' || 'ORACLE이다' FROM dual;

SELECT instr('이것이 ORACLE이다. 이것도 ORACLE이다','이것',2) FROM dual;

SELECT lower('abcdEFGH'), upper('abcdEFGH'), initcap('this is oracle') FROM dual;

SELECT replace('이것이 ORACLE이다','이것이','This is') FROM dual;

SELECT translate('이것이 ORACLE이다','이것이','AB') FROM dual;

SELECT substr('대한민국만세', 3, 2) FROM dual;

SELECT reverse('Oracle') FROM dual;

SELECT lpad('이것이',10,'##'), rpad('이것이',10, '##') FROM dual;

SELECT ltrim(' 이것이'), rtrim('이것이$$$$','$') FROM dual;

SELECT trim(' 이것이 '), trim(BOTH 'ㅋ' FROM 'ㅋㅋ재밌어요.ㅋㅋㅋㅋㅋㅋㅋ') FROM dual;

SELECT regexp_count('이것이 오라클이다','이') FROM dual;

-- 수학 관련 함수

SELECT abs(-100) FROM dual;

SELECT ceil(4.4), floor(4.4), round(4.4) FROM dual;

SELECT mod(13,4) FROM dual;

SELECT power(2,3) FROM dual;

SELECT sign(100), sign(0), sign(-100.123) FROM dual;

SELECT trunc(12345.12345,2), trunc(12345.12345,-2) FROM dual;

SELECT add_months('2025-01-01',5), add_months(sysdate,-5) FROM dual;

SELECT to_date('2025-01-01') + 5, sysdate -5 FROM dual;

SELECT extract(YEAR FROM DATE '2025-01-01'), extract(day FROM sysdate) FROM dual;

SELECT last_day('2025-02-01') FROM dual;

SELECT next_day('2025-03-21','금요일'), next_day(sysdate, '토요일') FROM dual;

SELECT round(months_between(sysdate, '2004-11-22')) FROM dual;

-- 형변환 함수

SELECT bin_to_num(1,0), bin_to_num(1,1,1,1) FROM dual;

SELECT bin_to_num(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1) FROM dual;

SELECT NUMTODSINTERVAL(48,'HOUR'), NUMTODSINTERVAL(360000,'SECOND') FROM dual;

SELECT NUMTOYMINTERVAL(37, 'MONTH'), NUMTOYMINTERVAL(1.5, 'YEAR') FROM dual;

--

SELECT row_number() 
OVER (ORDER BY height desc) "키 큰 순위", username, addr, height
FROM usertbl;

SELECT row_number() 
OVER (ORDER BY height asc) "키 큰 순위", username, addr, height
FROM usertbl;

SELECT addr, row_number() 
OVER (PARTITION BY addr ORDER BY height DESC, username asc)
"키 큰 순위", username, addr, height 
FROM usertbl;

SELECT dense_rank() 
OVER (ORDER BY height DESC)
"키 큰 순위", username, addr, height 
FROM usertbl;

SELECT rank() 
OVER (ORDER BY height DESC)
"키 큰 순위", username, addr, height 
FROM usertbl;

--라운드 로빈
SELECT NTILE(3) over(ORDER BY height desc)
"반번호", username, addr, height FROM usertbl;

SELECT username, addr, height AS "키",
height - (LEAD(height, 1, 0)
over(ORDER BY height desc))
AS "다음 사람과의 키 차이"
FROM usertbl;

SELECT username, addr, height AS "키",
height - (FIRST_VALUE(height)
over(PARTITION BY addr ORDER BY height desc))
AS "지역별 최대 키 차이"
FROM usertbl;

SELECT username, addr, height AS "키",
(cume_dist() 
over(PARTITION BY addr ORDER BY height desc)) * 100
AS "누적 인원 백분율 (%)"
FROM usertbl;

CREATE TABLE pivotTest(
	uname nchar(3),
	season nchar(2),
	amount NUMBER (3)
);

INSERT INTO PIVOTTEST VALUES ('김범수', '겨울', 10);
INSERT INTO PIVOTTEST VALUES ('윤종신', '여름', 15);
INSERT INTO PIVOTTEST VALUES ('김범수', '가을', 25);
INSERT INTO PIVOTTEST VALUES ('김범수', '봄', 3);
INSERT INTO PIVOTTEST VALUES ('김범수', '봄', 37);
INSERT INTO PIVOTTEST VALUES ('윤종신', '겨울', 40);
INSERT INTO PIVOTTEST VALUES ('김범수', '여름', 14);
INSERT INTO PIVOTTEST VALUES ('김범수', '겨울', 22);
INSERT INTO PIVOTTEST VALUES ('윤종신', '여름', 64);

SELECT * FROM pivotTest;

SELECT * FROM pivotTest
	pivot(sum(amount)
		FOR season
		IN('봄','여름','가을','겨울'));
