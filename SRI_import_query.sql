--SRI import headers look like 
--SIS_ID	GRADE	FIRST_NAME	LAST_NAME	USER_NAME	PASSWORD	SCHOOL_NAME	CLASS_NAME

--at rise usernames and passwords are first name.last name ; first name
select SIS_ID
      ,GRADE
      ,FIRST_NAME
      ,LAST_NAME
      ,lower(first_clean || '.' || last_clean) as USER_NAME
      ,lower(first_clean) as PASSWORD
      ,case when SIS_ID > 0 then 'Rise Academy' else null end as SCHOOL_NAME
      ,case when SIS_ID > 0 then 2019 else null end as CLASS_NAME
from
(select s.student_number as SIS_ID
      ,s.grade_level as GRADE
      ,s.first_name as FIRST_NAME
      ,s.last_name as LAST_NAME
      ,replace(s.first_name, '''','') as first_clean
      ,replace(s.last_name, '''','') as last_clean
      ,s.first_name as PASSWORD
from students s
left outer join reenrollments re on s.id = re.studentid
where s.enroll_status < 1 and re.entrydate is null and s.schoolid = 73252)
order by GRADE, LAST_NAME, FIRST_NAME