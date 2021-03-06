select base_studentid
      ,base_lastfirst
      ,base_schoolid
      ,base_grade_level
      ,absences_undoc + absences_doc as absences_total
      ,sum(mem_reg.studentmembership) as mem
      --days present
      ,sum(mem_reg.studentmembership) - (absences_undoc + absences_doc) as days_present
      --truancy (unexcused)
      ,absences_undoc as absences_toward_truancy
from
(select base_studentid
      ,base_lastfirst
      ,base_gender
      ,base_schoolid
      ,base_grade_level
      ,sum(case
           when att_code = 'A'
           then 1
           else 0
           end) as absences_undoc
      ,sum(case
           when att_code = 'AD'
           then 1
           when att_code = 'D'
           then 1
           else 0
           end) as absences_doc
      ,sum(case
           when att_code = 'T'
           then 1
           else 0
           end) as tardies_reg
       ,sum(case
           when att_code = 'T10'
           then 1
           else 0
           end) as tardies_T10
       ,sum(case
           when att_code = 'S'
           then 1
           else 0
           end) as ISS
       ,sum(case
           when att_code = 'OS'
           then 1
           else 0
           end) as OSS
from
(select studentid as base_studentid
       ,s.lastfirst as base_lastfirst
       ,s.gender as base_gender
       ,base_schoolid
       ,base_grade_level
       ,psad.att_date
       ,psad.att_code
from

--find ALL students enrolled at NCA during 2010-2011.  this is a combination of
--reenrollments table AND students table.  reenrollments has students who
--finished the year at NCA; students table has students who TRANSFERRED mid year.
--this base query gets both of those via a union operator.
(select distinct re.studentid as base_studentid
        --select distinct is kinda sloppy here...but a kid can tranfer in and out over the course of the year
        --and you don't want dupes.  so there you have it...
       ,re.schoolid as base_schoolid
       ,re.grade_level as base_grade_level
 from reenrollments re
 where re.entrydate >= '01-AUG-10' and re.exitdate < '01-JUL-11'
 union all
 select students.id as base_studentid
       ,students.schoolid as base_schoolid
       ,students.grade_level as base_grade_level
from students
where students.entrydate > '01-AUG-10'
  and students.enroll_status > 0 and students.exitdate > '01-AUG-10' and students.enroll_status != 3)
--end of the base query that finds all 2010-2011 students

left outer join students s on base_studentid = s.id and s.entrydate >= '01-AUG-10'
left outer join PS_ATTENDANCE_DAILY psad on base_studentid = psad.studentid 
                                                and psad.att_date >= '01-AUG-10'
                                                and psad.att_date <  '01-JUL-11'
                                                and psad.att_code is not null
order by base_schoolid, base_grade_level, s.lastfirst, psad.att_date)
group by base_studentid, base_lastfirst, base_gender, base_schoolid, base_grade_level
order by base_schoolid, base_grade_level, base_lastfirst)
left outer join pssis_membership_reg mem_reg on base_studentid = mem_reg.studentid 
                                                    and mem_reg.calendardate >  '01-AUG-10' 
                                                    and mem_reg.calendardate <= '01-JUL-11'
                                                    and mem_reg.calendarmembership = 1
group by base_studentid
        ,base_lastfirst
        ,base_gender
        ,base_schoolid
        ,base_grade_level
        ,absences_undoc
        ,absences_doc
        ,tardies_reg
        ,tardies_T10
        ,iss
        ,oss
order by base_grade_level, base_lastfirst;