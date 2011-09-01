 select base_studentid
       ,s.lastfirst
       ,base_schoolid
       ,base_grade_level
       ,grad_comment
       ,s.gender
from                        
(select re.studentid as base_studentid
       ,re.schoolid as base_schoolid
       ,re.grade_level as base_grade_level
       ,re.exitcomment as grad_comment
       --the row number function assigns a number to ALL the re-entry events for each student in the query
       --so if a student transfers in and out multiple times during the year, these will be numbered 1,2,3 etc.
       --by sorting by exit date descending, we put them in order from most recent - oldest.
       --turning this into a subquery allows us to take only rn = 1, ie the 'last' re-entry event of the year.
       ,row_number() over(partition by re.studentid order by re.exitdate desc) as rn
  from reenrollments re
  where re.entrydate >= '01-AUG-10' and re.exitdate < '01-JUL-11' and (re.exitdate - re.entrydate) > 0 and re.schoolid = 73253
  and re.grade_level = 12 and lower(re.exitcomment) like '%graduated%')
  left outer join students s on base_studentid = s.id
  where rn = 1
  