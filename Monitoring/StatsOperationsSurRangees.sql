Select object_schema_name(UStat.object_id) 
        + '.' + object_name(UStat.object_id) As [Object Name] 
    ,Case
        When Sum(User_Updates + User_Seeks + User_Scans + User_Lookups) = 0 Then Null
        Else Cast(Sum(User_Seeks + User_Scans + User_Lookups) As Decimal)
                    / Cast(Sum(User_Updates 
                                + User_Seeks 
                                + User_Scans
                                + User_Lookups) As Decimal(19,2))
        End As [Proportion of Reads] 
    , Case
        When Sum(User_Updates + User_Seeks + User_Scans + User_Lookups) = 0 Then Null
        Else Cast(Sum(User_Updates) As Decimal)
                / Cast(Sum(User_Updates 
                            + User_Seeks 
                            + User_Scans
                            + User_Lookups) As Decimal(19,2))
        End As [Proportion Of Writes] 
    , Sum(User_Seeks + User_Scans + User_Lookups) As [Total Read Ops] 
    , Sum(User_Updates) As [Total Write Ops]
From sys.dm_db_Index_Usage_Stats As UStat
    Join Sys.Indexes As I 
        On UStat.object_id = I.object_id
            And UStat.index_Id = I.index_Id
    Join sys.tables As T
        On T.object_id = UStat.object_id
Where I.Type_Desc In ( 'Clustered', 'Heap' )
