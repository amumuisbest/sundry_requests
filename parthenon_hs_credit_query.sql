--NEW

SELECT base.internalid
      ,base.grade_lev_2011_12
      ,year_in_hs.hs_year
      ,base.SID
      ,base.student
      ,schools.abbreviation AS school
      ,sg.course_name
      ,sg.grade
      ,sg.percent
      ,sg.potentialcrhrs
      ,sg.earnedcrhrs
FROM
     (SELECT cohort.studentid AS internalid
            ,cohort.grade_level AS grade_lev_2011_12
            ,cust.SID
            ,cohort.schoolid
            ,s.lastfirst
            ,s.first_name || ' ' || s.last_name AS student
      FROM cohort$comprehensive_long cohort
      JOIN students s 
        ON s.id = cohort.studentid
      JOIN custom_students cust
        ON s.id = cust.studentid
      WHERE cohort.year = 2011
        AND cohort.schoolid != 999999
        AND cohort.schoolid = 73253
      ) base
JOIN schools@PS_TEAM 
  ON base.schoolid = schools.school_number
JOIN storedgrades@PS_TEAM sg
  ON base.internalid = sg.studentid
 AND sg.termid >= 2100 
 AND sg.termid <  2200
 AND sg.potentialcrhrs > 0
LEFT OUTER JOIN
   (SELECT studentid
          ,year
          ,hs_year
    FROM
          (SELECT cohort.*
                 ,row_number() OVER
                    (PARTITION BY studentid
                     ORDER BY year ASC) AS hs_year 
          FROM cohort$comprehensive_long cohort
          WHERE schoolid = 73253
          ) 
    ) year_in_hs
  ON year_in_hs.studentid = base.internalid
  WHERE year_in_hs.year = 2011

;


;

--OLD
SELECT internal_id
      ,student_number
      ,state_id
      ,school
      ,school_year
      ,hs_year
      ,SUM(earnedcrhrs) AS credits_earned
      ,SUM(potentialcrhrs) AS credits_attempted
      ,LISTAGG(credit_element, ', ') 
         WITHIN GROUP (ORDER BY credit_element) AS elements_audit
FROM
      /*
      join to stored grades
      pull only storecode Y1 (for TEAM, at least, only Y1 grades are
      credit bearing for the year) and potentialcrhrs above 0.
      may want to put some sort of restriction on excludefromgpa != 1
      as well.
      */
     (SELECT hs_year.*
            ,sg.earnedcrhrs
            ,sg.potentialcrhrs
            ,schools.abbreviation AS school
            ,hs_year.school_year || ' ' || sg.course_name || ', ' || 
               round(sg.percent,0) || ' ' || sg.grade || ' (' || 
               sg.earnedcrhrs || '/' || sg.potentialcrhrs || ' ' || 
               sg.credit_type || ' cr)' AS credit_element
      FROM
            /*
            order and tag student enrollments to determine year in HS
            */
           (SELECT internal_id
                  ,student_number
                  ,state_id
                  ,termid
                  ,school_year
                  ,row_number() OVER
                     (PARTITION BY internal_id
                      ORDER BY termid ASC
                     ) AS hs_year
            FROM
                  (SELECT students.id AS internal_id
                        ,students.student_number AS student_number
                        --replace with wherever you store SID.  TEAM has this in a 
                        --custom field called 'SID'.
                        ,ps_customfields.getcf('Students',students.id,'SID') AS state_id
                        ,terms.id AS termid
                        ,terms.abbreviation AS school_year
                        ,row_number() OVER 
                        /*
                        enforce 1 row per student/enrollment year
                        order by last date of enrollment
                        this cleans the table to allow for count of years in school
                        
                        DO NOT partition by school id at this level - transfers between
                        schools will monkey wrench this query if you include schools.
                        Will bring in school detail above.
                        */
                           (PARTITION BY students.id
                                        ,terms.id
                            ORDER BY     ps_enrollment.exitdate DESC
                           ) AS rn
                  FROM students
                  JOIN ps_enrollment 
                    ON students.id = ps_enrollment.studentid
                   AND ps_enrollment.grade_level >= 9
                  JOIN terms ON terms.firstday <= ps_enrollment.entrydate
                   --PS asks schools to indicate exit dates 1 day after end of term
                   --so the end date on term needs to be upped by 1
                   --to match normal exit date for students
                   AND (terms.lastday + 1) >= ps_enrollment.exitdate 
                   AND terms.portion = 1
                   AND ps_enrollment.schoolid = terms.schoolid
                   ) base
            --because the RN logic partitions by student and enrollment year,
            --this pulls a rationalized enrollment view with one row per student/year
            --after initial 9th grade entry.  allows hs_year count above.
            WHERE rn = 1
            ORDER BY internal_id, termid
            ) hs_year
      JOIN storedgrades sg 
        ON sg.studentid = hs_year.internal_id
        AND sg.storecode = 'Y1'
        AND sg.potentialcrhrs > 0
        --ugly hack to account for fact that Y1 grades might be associated
        --with a semester term (eg 1802 for 2008 s2)
        AND hs_year.termid >= sg.termid
        AND hs_year.termid <  (sg.termid + 50)
      JOIN schools 
        ON sg.schoolid = schools.school_number
      ) with_grades
GROUP BY internal_id
        ,student_number
        ,state_id
        ,school
        ,school_year
        ,hs_year
        