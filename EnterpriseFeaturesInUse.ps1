# ref  https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-persisted-sku-features-transact-sql

# script to locate Enterprise features that are in use

# might be something that forces an upgrade path 

# might be worth running this in Dev and in CI pipeline to ensure no non-licensed features are incorporated into system development
$Server = "$ENV:COMPUTERNAME\sql2016"
$SMOServer = New-Object ('Microsoft.SQLServer.Management.Smo.Server') $Server

$sql = 
@'
SELECT feature_name FROM sys.dm_db_persisted_sku_features;  
GO
'@

foreach ($DB in $SMOServer.databases | Where-Object { $psitem.status -eq 'normal' }) {
    $r = Invoke-Sqlcmd -ServerInstance $($SMOServer.Name) -Database $($DB.name) -Query $sql 
    if ($r) {
        $t = $r.feature_name -join "; "
        $t | Select-Object @{name = "Database"; expression = { $($DB.name) } }, @{name = "Enterprise features"; expression = { $t } }
    }
}

<#
expect output for databases that are using these features like:
Database           Enterprise features
--------           -------------------
AdventureWorks2016 Compression; Partitioning; InMemoryOLTP
Example            Compression
sqlnexus           Compression; ColumnStoreIndex
tpcxbb_1gb         Compression; ColumnStoreIndex
WideWorldImporters ColumnStoreIndex; InMemoryOLTP
XE_Import          ColumnStoreIndex
#>