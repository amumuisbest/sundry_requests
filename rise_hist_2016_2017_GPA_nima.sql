select s.student_number
      ,s.id
      ,s.lastfirst
      ,sg.grade_level
      ,sg.course_name
      ,sg.grade
      ,round(sg.percent,0) as percent
      ,sg.potentialcrhrs
from students s
left outer join storedgrades sg on s.id = sg.studentid and sg.schoolid = 73252 and sg.storecode = 'Y1'
where s.schoolid = 73252 and s.grade_level >= 7 and s.enroll_status = 0 and sg.potentialcrhrs > 0
order by s.grade_level, s.lastfirst, sg.grade_level, sg.course_name