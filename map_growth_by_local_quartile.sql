select sch_10_11
      ,gr_lev_10_11
      ,local_quartile
      ,count(*) as N
      ,round(avg(fall_rit)    ,0) as avg_fall_rit
      ,round(avg(spr_rit)     ,0) as avg_spr_rit
      ,round(avg(growth_goal) ,0) as avg_growth_goal
      ,round(avg(act_growth)  ,0) as avg_act_growth
      ,round(avg(
      case when met_goal = 'yes' then 1
            when met_goal = 'no'  then 0
            else null
       end)*100                  
                              ,0) as pct_mtg_goal
      
from
      (select base_studentid
            ,sch.abbreviation as sch_10_11
            ,gr_lev_10_11
      
            ,map_fall_2010.testritscore as fall_rit
            ,map_spr_2011.testritscore as spr_rit
            
            ,map_fall_2010.testpercentile as fall_pctle
            ,map_spr_2011.testpercentile as spr_pctle
            
            ,map_fall_2010.typicalfalltospringgrowth as growth_goal
            ,map_spr_2011.testritscore - map_fall_2010.testritscore as act_growth
            
            ,case 
               when (map_fall_2010.typicalfalltospringgrowth is null or (map_spr_2011.testritscore - map_fall_2010.testritscore) is null) then null
               when (map_spr_2011.testritscore - map_fall_2010.testritscore) >= map_fall_2010.typicalfalltospringgrowth then 'yes' 
               when (map_spr_2011.testritscore - map_fall_2010.testritscore) <  map_fall_2010.typicalfalltospringgrowth then 'no' 
               else null 
             end as met_goal
             
            ,case
               when map_fall_2010.testritscore is null then null
               else ntile(4) over (partition by sch_10_11, gr_lev_10_11 
                                       order by map_fall_2010.testritscore asc) 
             end as local_quartile
            ,case 
               when map_fall_2010.testpercentile >= 1  and map_fall_2010.testpercentile <= 24 then 'Bottom'
               when map_fall_2010.testpercentile >= 25 and map_fall_2010.testpercentile <= 49 then 'Second'
               when map_fall_2010.testpercentile >= 50 and map_fall_2010.testpercentile <= 74 then 'Third'
               when map_fall_2010.testpercentile >= 75 and map_fall_2010.testpercentile <= 99 then 'Top'
               else null 
              end as national_quartile
      from
           (select base_studentid
                  ,base_schoolid as sch_10_11
                  ,base_grade_level as gr_lev_10_11
            from
                  (select re.studentid as base_studentid
                         ,re.schoolid as base_schoolid
                         ,re.grade_level as base_grade_level
                         --the row number function assigns a number to ALL the re-entry events for each student in the query
                         --so if a student transfers in and out multiple times during the year, these will be numbered 1,2,3 etc.
                         --by sorting by exit date descending, we put them in order from most recent - oldest.
                         --turning this into a subquery allows us to take only rn = 1, ie the 'last' re-entry event of the year.
                         ,row_number() over(partition by re.studentid order by re.exitdate desc) as rn
                   from reenrollments@PS_TEAM re
                   where re.entrydate >= '01-AUG-10' and re.exitdate < '01-JUL-11' and (re.exitdate - re.entrydate) > 0)
            where rn = 1
            union all
            --get the students who TRANSFERRED mid year last year.
            --logic here is to decode by entry date & enroll status
            --excluding schoolid 999999 makes sure that students who were transferred to 'graduated students' 
            --don't show up in this query.
            select students.id as base_studentid
                  ,students.schoolid as base_schoolid
                  ,students.grade_level as base_grade_level
            from students@PS_TEAM students
            where students.entrydate > '01-AUG-10' and students.entrydate < '28-JUN-11'
              and students.enroll_status > 0 and students.exitdate > '01-AUG-10' and students.schoolid != 999999 
              and (students.exitdate - students.entrydate) > 0)
      left outer join map_assessments_long map_fall_2010 on base_studentid = map_fall_2010.map_studentid 
                  and map_fall_2010.termname = 'Fall 2010' and map_fall_2010.measurementscale = 'Mathematics'
      
      left outer join map_assessments_long map_spr_2011 on base_studentid = map_spr_2011.map_studentid 
                  and map_spr_2011.termname = 'Spring 2011' and map_spr_2011.measurementscale = 'Mathematics'
      
      left outer join schools@PS_TEAM sch on sch_10_11 = sch.school_number)
where local_quartile is not null and act_growth is not null
group by sch_10_11
        ,gr_lev_10_11
        ,local_quartile
order by sch_10_11
        ,gr_lev_10_11
        ,local_quartile