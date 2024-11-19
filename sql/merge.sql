DECLARE		@SharePoint_List_GUID		AS NVARCHAR(36)		= '12345678-9012-3456-7890-123456789012'
DECLARE		@SharePoint_List_Title		AS NVARCHAR(512)	= 'Not Defined'
DECLARE		@ItemPriority				AS NVARCHAR(16)		= 'Normal'
DECLARE		@SLAMinutes					AS INT				= 480
DECLARE		@SLAGoal					AS NUMERIC(15,3)	= 0.95
DECLARE		@SLALow						AS NUMERIC(15,3)	= 0.85
DECLARE		@SLAMid						AS NUMERIC(15,3)	= 0.90
DECLARE		@SLAHigh					AS NUMERIC(15,3)	= 0.95



			MERGE	dbo.Communications_CS_SLA_Levels AS target_tbl
			USING	(SELECT			CONVERT(UNIQUEIDENTIFIER, @SharePoint_List_GUID)
									, @SharePoint_List_Title
									, @ItemPriority
									, @SLAMinutes
									, @SLAGoal
									, @SLALow
									, @SLAMid
									, @SLAHigh
					) 
					AS source_item
					(ListGUID
					, SharePointListTitle
					, ItemPriority
					, SLAMinutes
					, SLAGoal
					, SLALow
					, SLAMid
					, SLAHigh
					)
					ON (target_tbl.ListGUID = source_item.ListGuid)
					WHEN MATCHED THEN
						UPDATE	SET
								  SharePointListTitle	= source_item.SharePointListTitle
								, ItemPriority			= source_item.ItemPriority
								, SLAMinutes			= source_item.SLAMinutes
								, SLAGoal				= source_item.SLAGoal		
								, SLALow				= source_item.SLALow
								, SLAMid				= source_item.SLAMid
								, SLAHigh				= source_item.SLAHigh
					WHEN NOT MATCHED THEN
						INSERT 
							( ListGUID
							, SharePointListTitle
							, ItemPriority
							, SLAMinutes
							, SLAGoal
							, SLALow
							, SLAMid
							, SLAHigh
							)
						VALUES
							(source_item.ListGUID
							, source_item.SharePointListTitle
							, source_item.ItemPriority
							, source_item.SLAMinutes
							, source_item.SLAGoal
							, source_item.SLALow
							, source_item.SLAMid
							, source_item.SLAHigh
							)
			; -- end merge
		END
;
