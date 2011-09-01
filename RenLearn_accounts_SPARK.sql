select SID
      ,SFIRST
      ,SLAST
      ,SGENDER
      ,SBIRTHDAY
      ,SRACE
      ,SGRADE
      ,SUSERNAME || (case when rn = 0 then null else rn end) as SUSERNAME
      ,SPASSWORD
      ,'AR' as course
      ,SGRADE || ': ' || team as class
      ,TFIRST
      ,TLAST
--uncomment line below if trying to update whole grade level 'classes'
--      ,2024 + (-1 * (case when SGRADE = 'K' then 0 else SGRADE * 1 end)) as class
from
      (select SID, SFIRST, SLAST, SGENDER, SBIRTHDAY, SRACE, SGRADE, team
             ,SUSERNAME, SPASSWORD
             ,case 
                when team = 'ASU'        then 'Ramdhanie'
                when team = 'Bowdoin'    then 'Estevez'
                when team = 'Columbia'   then 'Iversen'
                when team = 'Cornell'    then '''O’Sullivan'''
                when team = 'Delaware'   then 'Cirigliano'
                when team = 'Johns Hopk' then 'Saunders'
                when team = 'Maryland'   then 'Boyle'
                when team = 'Mt Holyoke' then 'Ronallo'
                when team = 'Northweste' then 'Eustis'
                when team = 'Princeton'  then 'Traub'
                when team = 'Rowan'      then 'Brown'
                when team = 'Tufts'      then 'Davis'
                when team = 'UCLA'       then 'Gersh'
                when team = 'UVA'        then 'Pollack'
                else null end TLAST
             ,case 
                when team = 'ASU'        then 'Lakeesha'
                when team = 'Bowdoin'    then 'Elsy'
                when team = 'Columbia'   then 'Matt'
                when team = 'Cornell'    then 'Antonia'
                when team = 'Delaware'   then 'Maryclare'
                when team = 'Johns Hopk' then 'Emma'
                when team = 'Maryland'   then 'Michelle'
                when team = 'Mt Holyoke' then 'Emilie'
                when team = 'Northweste' then 'Jackie'
                when team = 'Princeton'  then 'Samantha'
                when team = 'Rowan'      then 'KeLee'
                when team = 'Tufts'      then 'Justin'
                when team = 'UCLA'       then 'Jessica'
                when team = 'UVA'        then 'Jenna'
                else null end TFIRST
               ,row_number() over(partition by SUSERNAME
                                                         order by SGRADE, SLAST, SFIRST desc) - 1 as rn
      from
            (select SID, SFIRST, SLAST, SGENDER, SBIRTHDAY, SRACE, SGRADE, team
                   ,substr(lower(first04), 1, 1) || last04 as SUSERNAME
                   ,replace(lower(first04), '''') as SPASSWORD
            from      
                  (select SID, SFIRST, SLAST, SGENDER, SBIRTHDAY, ALT_BIRTHDAY, SRACE, SGRADE, team
                         ,replace(replace(last03,''''),'`') as last04
                         ,replace(replace(first03,''''),'`') as first04
                  from
                        (select SID, SFIRST, SLAST, SGENDER, SBIRTHDAY, ALT_BIRTHDAY, SRACE, SGRADE, team
                               ,replace(last02, ' ') as last03
                               ,replace(first02, ' ') as first03
                        from
                              (select SID, SFIRST, SLAST, SGENDER, SBIRTHDAY, ALT_BIRTHDAY, SRACE, SGRADE, team
                                     ,case when substr(last01, 1, instr(last01,'-',1,1)-1) is null then last01
                                           else substr(last01, 1, instr(last01,'-',1,1)-1) end last02
                                     ,replace(first01, '-') as first02                                       
                              from
                                    (select s.student_number as SID
                                           ,s.first_name as SFIRST
                                           ,s.last_name as SLAST
                                           ,s.gender as SGENDER 
                                           ,to_char(s.dob, 'mm/dd/yyyy') as SBIRTHDAY
                                           ,to_char(s.dob, 'dd') as ALT_BIRTHDAY
                                           ,s.ethnicity as SRACE
                                           ,s.team
                                           ,case 
                                             when s.grade_level = 0 
                                             then 'K'
                                             else to_char(s.grade_level) end SGRADE
                                           ,case 
                                              when instr(s.last_name, ',') > 0
                                              then lower(substr(s.last_name, 1, instr(s.last_name, ',')-1))
                                              else lower(s.last_name) end last01
                                           ,case 
                                              when instr(s.first_name, ',') > 0
                                              then lower(substr(s.first_name, 1, instr(s.first_name, ',')-1))
                                              else lower(s.first_name) end first01
                                    from students s
                                    where s.enroll_status <= 0 and s.schoolid = 73254
                                    order by s.grade_level, s.lastfirst))))))
order by SGRADE desc, SLAST, SFIRST