# PowerShell that references SQL Server Configuration properties and compares RunValue to ConfigValue and shows of there are pending changes


[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null 
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMOExtended') | Out-Null 
 
$Server = "$ENV:COMPUTERNAME\sql2016"
$SMOServer = new-object ('Microsoft.SQLServer.Management.Smo.Server') $Server

$($smoserver.Configuration | Select-Object -ExpandProperty properties | Select-Object displayname, runvalue, configvalue, @{name = "Diff"; expression = {$(if($_.runvalue -ne $_.configvalue){"* difference *"}else{"same"})}}) | Format-Table -a 


<#
Sample output

DisplayName                       RunValue ConfigValue Diff          
-----------                       -------- ----------- ----          
cost threshold for parallelism           5          50 * difference *
show advanced options                    1           0 * difference *
access check cache bucket count          0           0 same          
access check cache quota                 0           0 same          
Ad Hoc Distributed Queries               0           0 same          
affinity I/O mask                        0           0 same          
affinity mask                            0           0 same          
affinity64 I/O mask                      0           0 same          
affinity64 mask                          0           0 same          
Agent XPs                                0           0 same          
allow updates                            0           0 same          
backup compression default               0           0 same          
blocked process threshold (s)            0           0 same          
c2 audit mode                            0           0 same          
clr enabled                              0           0 same          
contained database authentication        0           0 same          
cross db ownership chaining              0           0 same          
cursor threshold                        -1          -1 same          
Database Mail XPs                        1           1 same          
default full-text language            1033        1033 same          
default language                         0           0 same          
default trace enabled                    1           1 same          
disallow results from triggers           0           0 same          
filestream access level                  0           0 same          
fill factor (%)                          0           0 same          
ft crawl bandwidth (max)               100         100 same          
ft crawl bandwidth (min)                 0           0 same          
ft notify bandwidth (max)              100         100 same          
ft notify bandwidth (min)                0           0 same          
index create memory (KB)                 0           0 same          
in-doubt xact resolution                 0           0 same          
lightweight pooling                      0           0 same          
locks                                    0           0 same          
max degree of parallelism                0           0 same          
max full-text crawl range                4           4 same          
max server memory (MB)               61320       61320 same          
max text repl size (B)               65536       65536 same          
max worker threads                       0           0 same          
media retention                          0           0 same          
min memory per query (KB)             1024        1024 same          
min server memory (MB)                4096        4096 same          
nested triggers                          1           1 same          
network packet size (B)               4096        4096 same          
Ole Automation Procedures                0           0 same          
open objects                             0           0 same          
optimize for ad hoc workloads            0           0 same          
PH timeout (s)                          60          60 same          
precompute rank                          0           0 same          
priority boost                           0           0 same          
query governor cost limit                0           0 same          
query wait (s)                          -1          -1 same          
recovery interval (min)                  0           0 same          
remote access                            1           1 same          
remote admin connections                 0           0 same          
remote login timeout (s)                10          10 same          
remote proc trans                        0           0 same          
remote query timeout (s)               600         600 same          
Replication XPs                          0           0 same          
scan for startup procs                   0           0 same          
server trigger recursion                 1           1 same          
set working set size                     0           0 same          
SMO and DMO XPs                          1           1 same          
transform noise words                    0           0 same          
two digit year cutoff                 2049        2049 same          
user connections                         0           0 same          
user options                             0           0 same          
xp_cmdshell                              0           0 same          
#>
