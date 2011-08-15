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

select student_web_id
      ,student_web_password
--      ,family_web_id
--      ,family_web_password
      ,first_name
      ,last_name
      ,twin_hash
      ,previous
      ,next
from
      (select student_web_id
            ,student_web_password
            ,family_web_id
            ,family_web_password
            ,twin_hash
            ,first_name
            ,last_name
            ,lag(twin_hash,1) over (order by last_name,dob) as previous
            ,lead(twin_hash,1) over (order by last_name,dob) as next
      from
            (select lower(
                         replace(replace(replace(replace(s.last_name, '''',''),'.',''),' ',''),',','')
                        ) || to_char(dob,'DD') || '.student'
                        as student_web_id
                  ,lower(
                         replace(replace(replace(replace(s.last_name, '''',''),'.',''),' ',''),',','')
                        ) || to_char(dob,'YY')
                        as student_web_password
                  ,lower(
                         replace(replace(replace(s.last_name, '''',''),'.',''),' ','')
                        ) || to_char(dob,'DD') || '.family'
                        as family_web_id
                  ,lower(
                         replace(replace(replace(replace(s.last_name, '''',''),'.',''),' ',''),',','')
                        ) || to_char(dob,'YY')
                        as family_web_password      
                  ,s.lastfirst
                  ,s.first_name
                  ,s.last_name
                  ,s.dob
                  ,lower(last_name) || '@' || to_char(dob,'MMDDYY') as twin_hash
            from students s)) 
;