
SELECT		p.spid
			,   RIGHT(convert(varchar, 
						dateadd(ms, datediff(ms, P.last_batch, getdate()), '1900-01-01'), 
				121), 12) as 'batch_duration'
			,   P.program_name
			,   P.hostname
			,   P.loginame
FROM		master.dbo.sysprocesses P
WHERE		P.spid > 50
			AND      P.status not in ('background', 'sleeping')
			AND      P.cmd not in ('AWAITING COMMAND'
                    ,'MIRROR HANDLER'
                    ,'LAZY WRITER'
                    ,'CHECKPOINT SLEEP'
                    ,'RA MANAGER')
ORDER BY	batch_duration	DESC