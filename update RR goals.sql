USE KIPP_NJ
GO
--COMMIT TRANSACTION
WITH new_rr_goals AS
				(SELECT * 
				FROM OPENROWSET(
						'MSDASQL'
					,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
					,'select * from C:\Users\winsql_service\Downloads\rr_nca_combined.csv')
				)
MERGE MAP$rutgers_ready_goals target
USING new_rr_goals source
			ON target.studentid = source.studentid
  AND target.measurementscale = source.measurementscale
  AND target.academic_year = source.academic_year
  AND target.end_grade = source.end_grade
  AND target.act_goal = source.act_goal
WHEN MATCHED THEN
		UPDATE SET  
				target.RIT_target = source.RIT_target
WHEN NOT MATCHED BY target THEN
INSERT (studentid
       ,measurementscale
       ,academic_year
       ,end_grade
       ,act_goal
       ,RIT_target) 
VALUES (source.studentid
       ,source.measurementscale
       ,source.academic_year
       ,source.end_grade
       ,source.act_goal
       ,source.RIT_target);


