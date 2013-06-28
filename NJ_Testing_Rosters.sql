--HSPAR PRE ID and BIO EOC PRE ID Rosters


--HSPA PRE ID
--HSPA PRE ID
--HSPA PRE ID
--HSPA PRE ID

select
     ps_customfields.getcf('Students',id,'SID')     as SID
    ,s.grade_level                                  as Grade
    ,s.last_name                                    as Last_Name
    ,s.first_name                                   as First_Name
    ,null                                           as Middle_Initial   
    ,s.dob                                          as Date_of_birth
    ,s.gender                                       as sex
    ,case 
        when s.ethnicity = 'W' then 'W'
        else null                                  end Ethnic_Code_W
    ,case 
        when s.ethnicity = 'B' then 'B'
        else null                                  end Ethnic_Code_B
    ,case 
        when s.ethnicity = 'A' then 'A'
        else null                                  end Ethnic_Code_A
    ,case 
        when s.ethnicity = 'P' then 'P'
        else null                                  end Ethnic_Code_P
    ,case 
        when s.ethnicity = 'H' then 'H'
        else null                                  end Ethnic_Code_H
    ,case 
        when s.ethnicity = 'I' then 'I'
        else null                                  end Ethnic_Code_I
    ,s.student_number                               as School_Student_ID_Number
    ,null                                           as Title_1_Math
    ,null                                           as Title_1_LAL
    ,case 
        when s.lunchstatus = 'F' then 'Y'
        when s.lunchstatus = 'R' then 'Y'
        else null                                  end ED
    ,null                                           as Homeless
    ,null                                           as MI
    ,null                                           as LEP
    ,null                                           as Section_504
    ,ps_customfields.getcf('Students',id,'SPEDLEP_Codes')     
                                                    as SE
    ,null                                           as SE_504_Accom_A
    ,null                                           as SE_504_Accom_B
    ,null                                           as SE_504_Accom_C
    ,null                                           as SE_504_Accom_D
    ,null                                           as IEP_Exempt_From_Taking_Math
    ,null                                           as IEP_Exempt_From_Taking_LAL
    ,null                                           as IEP_Exempt_From_Passing_Math
    ,null                                           as IEP_Exempt_From_Passing_LAL
    ,case
        when s.districtentrydate > '01-JUL-12' then 'Y'
        else null                                  end TID_1
    ,case
        when s.districtentrydate > '01-JUL-12' then 'Y'
        else null                                  end TIS_1
    ,null                                           as SES
    ,null                                           as Sending_School_CDS
from students s
where s.schoolid = 73253 and s.grade_level = 11 and s.enroll_status = 0

;

--NJ BTC PRE ID
--NJ BTC PRE ID
--NJ BTC PRE ID
--NJ BTC PRE ID

select 
         SID
        ,Grade
        ,Last_Name
        ,First_Name
        ,Middle_Initial   
        ,Date_of_birth
        ,sex
        ,Ethnic_Code_W
        ,Ethnic_Code_B
        ,Ethnic_Code_A
        ,Ethnic_Code_P
        ,Ethnic_Code_H
        ,Ethnic_Code_I
        ,School_Student_ID_Number
        ,Title_1_Biology
        ,ED
        ,Homeless
        ,MI
        ,LEP
        ,Section_504
        ,SE
        ,SE_504_Accom_A
        ,SE_504_Accom_B
        ,SE_504_Accom_C
        ,SE_504_Accom_D
        ,IEP_Exempt_From_Taking_NJBCT
        ,IEP_Exempt_From_Passing_NJBCT
        ,case when cc.course_number = 'SCI20' then 22
              when cc.course_number = 'SCI25' then 32
              else null end as course
        ,schedule
        ,TID_1
        ,TIS_1
        ,SES
        ,Sending_School_CDS
from
     (select s.id as base_studentid
            ,s.schoolid as base_schoolid
            ,ps_customfields.getcf('students',s.id,'SID')   as SID
            ,s.grade_level                                  as Grade
            ,s.last_name                                    as Last_Name
            ,s.first_name                                   as First_Name
            ,null                                           as Middle_Initial   
            ,s.dob                                          as Date_of_birth
            ,s.gender                                       as sex
            ,case 
                when s.ethnicity = 'W' then 'W'
                else null                                  end Ethnic_Code_W
            ,case 
                when s.ethnicity = 'B' then 'B'
                else null                                  end Ethnic_Code_B
            ,case 
                when s.ethnicity = 'A' then 'A'
                else null                                  end Ethnic_Code_A
            ,case 
                when s.ethnicity = 'P' then 'P'
                else null                                  end Ethnic_Code_P
            ,case 
                when s.ethnicity = 'H' then 'H'
                else null                                  end Ethnic_Code_H
            ,case 
                when s.ethnicity = 'I' then 'I'
                else null                                  end Ethnic_Code_I
            ,s.student_number                               as School_Student_ID_Number
            ,null                                           as Title_1_Biology
            ,case 
                when s.lunchstatus = 'F' then 'Y'
                when s.lunchstatus = 'R' then 'Y'
                else null                                  end ED
            ,null                                           as Homeless
            ,null                                           as MI
            ,null                                           as LEP
            ,null                                           as Section_504
            ,ps_customfields.getcf('students',s.id,'SPEDLEP_Codes')     
                                                            as SE
            ,null                                           as SE_504_Accom_A
            ,null                                           as SE_504_Accom_B
            ,null                                           as SE_504_Accom_C
            ,null                                           as SE_504_Accom_D
            ,null                                           as IEP_Exempt_From_Taking_NJBCT
            ,null                                           as IEP_Exempt_From_Passing_NJBCT
            ,'F'                                            as schedule
            ,case
                when s.districtentrydate > '01-JUL-12' then 'Y'
                else null                                  end TID_1
            ,case
                when s.districtentrydate > '01-JUL-12' then 'Y'
                else null                                  end TIS_1
            ,null                                           as SES
            ,null                                           as Sending_School_CDS
      from students s
      where s.enroll_status = 0 and s.schoolid = 73253)
      
join cc on cc.studentid = base_studentid 
       and cc.schoolid = base_schoolid 
       and cc.termid >= 2200 
       and cc.dateenrolled <= sysdate and cc.dateleft >= sysdate
       and cc.course_number in ('SCI20','SCI25')
--join sections sect on cc.sectionid = sect.id
--join courses c on sect.course_number = c.course_number 
--       and c.course_number IN ('SCI20','SCI25')


;


--NJASK Rosters
--NJASK Rosters

select
     student_number as LocalIdentificationNumber
    ,ps_customfields.getcf('students',s.id,'SID') as StateIdentificationNumber
    ,first_name as FirstName
    ,last_name as LastName
    ,DOB as DateOfBirth
    ,null as Section504
    ,null as SE504SettingAccom
    ,null as SE504ScheduleAccom
    ,null as SE504TestMaterialAccom
    ,null as SE504TestProcedureAccom
    ,null as APAScienceTest
    ,null as APAMathTest
    ,null as APALanguageTest
    ,null as LEPExemptFromTakingLAL
    ,case
      when districtentrydate >= '01-JUL-12' then 'Y'
      else 'N'
      end as TimeInDistrictLessThanOneYear
    ,case
      when districtentrydate >= '01-JUL-12' then 'Y'
      else 'N'
      end as TimeInSchoolLessThanOneYear
    ,80 as StateAss_TestingSiteCounty
    ,7325 as StateAss_TestingSiteDistrict
    ,965 as StateAss_TestingSiteSchool
    ,80 as StateAss_AccountableCounty
    ,7325 as StateAss_AccountableDistrict
    ,965 as StateAss_AccountableSchool
    ,null as ExaminerSMIDDay1
    ,null as ExaminerSMIDDay2
    ,null as ExaminerSMIDDay3
    ,null as ExaminerSMIDDay4
    ,null as ExaminerSMIDDay5
from students s
where s.enroll_status = 0
  and s.grade_level >= 3
  and s.grade_level <= 8
order by s.schoolid,s.grade_level,s.lastfirst


;
--district entry date fix
select *
from
(select 
   s.schoolid
  ,s.student_number
  ,s.lastfirst
  ,s.grade_level
  ,re.entrydate
  ,s.districtentrydate
  ,CASE WHEN s.schoolid = 1000000 THEN NULL
        else row_number() OVER (PARTITION BY re.studentid--,re.entrydate
                          ORDER BY re.studentid,re.entrydate)
                          end as row_count
from reenrollments re
join students s on re.studentid = s.id
where s.enroll_status = 0
--  and entrydate >= '6-SEP-12'
    and districtentrydate <= '01-JAN-02'
    )
where row_count = 1