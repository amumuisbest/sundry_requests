--SRI import headers look like 
--SIS_ID	GRADE	FIRST_NAME	LAST_NAME	USER_NAME	PASSWORD	SCHOOL_NAME	CLASS_NAME

--at rise usernames and passwords are first name.last name ; first name
select SIS_ID
      ,GRADE
      ,FIRST_NAME
      ,LAST_NAME
      ,USER_NAME
      ,PASSWORD
      ,case when SIS_ID > 0 then 'Rise Academy' else null end as SCHOOL_NAME
      ,2024 + (-1 * GRADE) as CLASS_NAME
from
(select s.student_number as SIS_ID
      ,s.grade_level as GRADE
      ,s.first_name as FIRST_NAME
      ,s.last_name as LAST_NAME
      ,replace(s.first_name, '''','') as first_clean
      ,replace(s.last_name, '''','') as last_clean
      ,student_web_id as USER_NAME
      ,student_web_password as PASSWORD
from students s
left outer join reenrollments re on s.id = re.studentid
where s.enroll_status < 1 and re.entrydate is null and s.schoolid = 133570965)
order by GRADE, LAST_NAME, FIRST_NAME