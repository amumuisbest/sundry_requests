select 'NCA' as field_siteShortName
      ,'P ' || s.student_number as field_barcode
      ,s.student_number as field_districtID
      ,s.last_name as field_lastName
      ,s.first_name as field_firstName
      ,case 
         when c.course_name is null then 'No Homeroom' 
         else c.course_name || ': ' || t.last_name 
       end as field_homeroom
      ,case when s.enroll_status = 0 then 'A' else 'I' end as field_status
      ,s.gender as field_gender
      ,s.grade_level as field_gradeLevel
      ,s.student_web_id as field_username
      ,s.student_web_password as field_password
      
from students s
left outer join cc on s.id = cc.studentid and cc.termid >= 2100 and cc.expression in ('5(A)', '6(A)', '7(A)', '8(A)')
left outer join sections sect on cc.sectionid = sect.id
left outer join courses c on sect.course_number = c.course_number
left outer join teachers t on sect.teacher = t.id
where s.schoolid = 73253 and s.enroll_status = 0