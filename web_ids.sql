--create web IDs for powerschool for all kids who do not have web ids
--convention is u: last name, birthday  pw: martin birth year
--eg u: martin57 pw: martin82

--we use these student usernames and passwords in:
--powerschool
--accelerated reader

--max length username
--powerschool: 20 characters total
--accelerated reader: XX characters

--the clean functions clear out: apostrophes, spaces, periods, commas, the word 'jr' from last names...

select student_number
      ,case 
            when dupe_flag is null then student_web_id
            when dupe_flag = 1 then alt_student_web_id
            else null end as student_web_id
      ,student_web_password
      ,case 
            when dupe_flag is null then family_web_id
            when dupe_flag = 1 then alt_family_web_id
            else null end as family_web_id
      ,family_web_password
      ,dupe_flag
from
      (select student_number
            ,student_web_id
            ,student_web_password
            ,family_web_id
            ,family_web_password
            ,alt_student_web_id
            ,alt_family_web_id
            --a duplicate is defined as someone who has the same web id as the person ABOVE or BELOW them.  this logic sets a flag.
            ,case when (student_web_id = previous OR student_web_id = next) then 1 else null end as dupe_flag
      from
            (select student_number 
                  ,student_web_id
                  ,student_web_password
                  ,family_web_id
                  ,family_web_password
                  ,alt_student_web_id
                  ,alt_family_web_id
                  --lag and lead allow us to make in-row comparisons to the previous/next student by last name & DOB.  this will determine twin-ness.
                  ,lag(student_web_id,1) over (order by student_web_id) as previous
                  ,lead(student_web_id,1) over (order by student_web_id) as next                 
            from
                  (select student_number
                          ,case when length(replace(replace(replace(replace(last_name, '''',''),'.',''),' ',''),',','') || to_char(dob,'DD')) > 12 
                                then lower(substr(replace(replace(replace(replace(last_name, '''',''),'.',''),' ',''),',',''), 1, (12 - length(to_char(dob,'DD'))))) || to_char(dob,'DD') || '.student'
                                else
                                    lower(
                                           replace(replace(replace(replace(last_name, '''',''),'.',''),' ',''),',','')
                                          ) || to_char(dob,'DD') || '.student' end
                                as student_web_id
                          ,lower(
                                 replace(replace(replace(replace(last_name, '''',''),'.',''),' ',''),',','')
                                ) || to_char(dob,'YY')
                                as student_web_password
                          ,case when length(replace(replace(replace(replace(last_name, '''',''),'.',''),' ',''),',','') || to_char(dob,'DD')) > 12 
                                then lower(substr(replace(replace(replace(replace(last_name, '''',''),'.',''),' ',''),',',''), 1, (12 - length(to_char(dob,'DD'))))) || to_char(dob,'DD') || '.family'
                                else
                                    lower(
                                           replace(replace(replace(replace(last_name, '''',''),'.',''),' ',''),',','')
                                          ) || to_char(dob,'DD') || '.family' end
                                as family_web_id
                          ,lower(
                                 replace(replace(replace(replace(last_name, '''',''),'.',''),' ',''),',','')
                                ) || to_char(dob,'YY')
                                as family_web_password
                          --alternate web ids that use first name for duplicates    
                          ,lower(
                                 replace(replace(replace(replace(first_name, '''',''),'.',''),' ',''),',','')
                                ) || to_char(dob,'DD') || '.student'
                                as alt_student_web_id
                          ,lower(
                                 replace(replace(replace(replace(first_name, '''',''),'.',''),' ',''),',','')
                                ) || to_char(dob,'DD') || '.family'
                                as alt_family_web_id                        
                          ,lastfirst
                          ,first_name
                          ,last_name
                          ,dob
                          
                  from 
                        --pre-process all last names to drop the hyphen and only use the first last name.
                        (select student_number
                               ,case when substr(last_name, 1, instr(last_name,'-',1,1)-1) is null then last_name
                                else substr(last_name, 1, instr(last_name,'-',1,1)-1) end as last_name
                               ,first_name
                               ,lastfirst
                               ,dob
                         from students s
                         where enroll_status = 0)))) 
;