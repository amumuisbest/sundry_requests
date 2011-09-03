select stu_name
      ,course_num
      ,c.course_name
      ,Y1
from
(select  lastfirst as stu_name
       ,course_number as course_num
       ,Y1
       ,row_number() over(partition by course_number
                          order by Y1 desc) as rn
from NCA_GRADES_EXTENDED
where Y1 is not null)
join courses@PS_TEAM c on course_num = c.course_number
where rn = 1
