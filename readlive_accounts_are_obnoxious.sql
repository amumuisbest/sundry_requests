select case when instr(s.first_name, ' ', 1) > 0 
            then substr(s.first_name, 1, instr(s.first_name,' ', 1))
            else s.first_name end as "Student First Name"
      ,replace(s.last_name,' ','-') as "Student Last Name"
      ,s.student_number as "Student ID"
      ,s.grade_level as "Student Grade"
      ,s.student_web_id as "Student User ID"
      ,s.student_web_password as "Student Password"
      ,case when regexp_count(s.mother,  '( )(.)') > 1 then null else
       case when s.mother is null then null else 'Mother' end end as "Parent 1 Relationship"
      ,case when regexp_count(s.mother,  '( )(.)') > 1 then null else
       trim(trailing ' ' from regexp_substr (s.mother,  '(..+)( ){1}', 1)) end as "Parent1 First Name"
      ,case when regexp_count(s.mother,  '( )(.)') > 1 then null else
       trim(leading ' ' from regexp_substr (s.mother,  '( )(..+){2}', 1)) end as "Parent1 Last Name"
      ,case when length(custom_students.mother_cell) > 12 
            then null 
            else custom_students.mother_cell end as "Parent1 Phone"
      ,'' as "Parent1 Phone Ext"
      ,case when instr(local_emails.contactemail, ',',1) > 0
            then replace(regexp_substr(local_emails.contactemail, '(.+)(,){1}'),',','')
            when instr(local_emails.contactemail, ';',1) > 0
            then replace(regexp_substr(local_emails.contactemail, '(.+)(;){1}'),',','')
            else local_emails.contactemail end as "Parent1 Email"
      ,case when regexp_count(s.father,  '( )(.)') > 1 then null else
       case when s.father is null then null else 'Father' end end as "Parent 2 Relationship"
      ,case when regexp_count(s.father,  '( )(.)') > 1 then null else
       trim(trailing ' ' from regexp_substr (s.father,  '(..+)( ){1}', 1)) end as "Parent2 First Name"
      ,case when regexp_count(s.father,  '( )(.)') > 1 then null else
       trim(leading ' ' from regexp_substr (s.father,  '( )(..+){2}', 1)) end as "Parent2 Last Name"
      ,case when length(custom_students.father_cell) > 12 
            then null 
            else custom_students.father_cell end as "Parent2 Phone"
      ,'' as "Parent2 Phone Ext"
      ,'' as "Parent2 Email"
      ,gender as "Sex"
      ,'' as "Title I"
      ,case when custom_students.spedlep like '%SPED%' then 'X' else null end as "Special Education"
      ,'' as "ELL/LEP"
      ,case when lower(s.lunchstatus) = 'f' then 'X'
            when lower(s.lunchstatus) = 'r' then 'X'
            else '' end as "Free/Reduced Lunch"
      ,case when lower(s.ethnicity) not in ('a','b','h','i','w') then null else s.ethnicity end as "Race"
from students@PS_TEAM s
left outer join custom_students on s.id = custom_students.studentid
left outer join local_emails on s.id = local_emails.studentid
where s.schoolid = 73252 and s.enroll_status = 0
order by s.grade_level, s.lastfirst