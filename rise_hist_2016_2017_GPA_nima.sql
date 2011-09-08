select student_number
      ,lastfirst
      ,cur_gl
      ,count(gpa_points) as total_stored_grades
      ,round(sum(gpa_points)/count(gpa_points),2) as hist_gpa
      ,listagg(hash, ', ') within group (order by hash) as elements
from
     (select student_number
            ,id
            ,lastfirst
            ,cur_gl
            ,grade_level as gl
            ,course_name
            ,storecode
            ,grade
            ,percent
            ,gpa_points
            ,hash
      from
           (select s.student_number
                  ,s.id
                  ,s.lastfirst
                  ,s.grade_level as cur_gl
                  ,sg.grade_level
                  ,sg.course_name
                  ,sg.storecode
                  ,sg.grade
                  ,round(sg.percent,0) as percent
--2008-09 gpa points are not stored correctly.  need a workaround until we go do some cleanup!
--                  ,round(sg.gpa_points,2) as gpa_points
                  ,case 
                   when sg.percent >= 90 then 4
                   when sg.percent >= 87 then 3.3
                   when sg.percent >= 80 then 3
                   when sg.percent >= 77 then 2.3
                   when sg.percent >= 70 then 2
                   when sg.percent >= 67 then 1.3
                   when sg.percent >= 65 then 1
                   when sg.percent  < 65 then 0
                   else null 
                   end gpa_points
                  ,sg.grade_level || ' ' || sg.course_name || ' (' || round(sg.percent,0) || ')' as hash 
            from students@PS_TEAM s
            left outer join storedgrades@PS_TEAM sg on s.id = sg.studentid and sg.schoolid = 73252 and sg.storecode = 'Y1'
            where s.schoolid = 73252 and s.grade_level >= 7 and s.enroll_status = 0 and sg.potentialcrhrs > 0))
group by student_number, lastfirst, cur_gl
order by cur_gl, lastfirst