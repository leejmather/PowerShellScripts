############
<# 
    This script assume the Azure RM module is installed and will create the following resources 
        Resource group
        Azure SQL Server
        Azure SQL Datbases
        Allow Azure Services to access the SQL server
    The script is provided as is and must be tested prior to use
#> 
###########

# Import the Azure RM module
Import-Module AzureRM
# Connect to Azure
Connect-AzureRMAccount

# Set the required values
$AZSubID = "314819cf-890a-453d-ca02-f56e001hh32d" # Azure Dubscription ID
$AZResGroup = "AZSQLUKSouth" # Resource Group Name
$AZlocation = "northeurope" # Resource location
$AZSQLServer = "leeazsqlserver" # Azure SQL Server name
$ProdDBName = "Lee_AzureSQL_Prod" # Azure SQL Prod database name
$TestDBName = "Lee_AzureSQL_Test" # Azure SQL Test database name
$AzureSQLDBTier = "S1" # Azure SQL Databbase tier
$MyIP = "92.12.214.173" # Home IP address to connect to Azure SQL

# Set the correct Azure subscription
Set-AzureRmContext -Subscription $AZSubID
# Create the Azure Resource Group
New-AzureRmResourceGroup -Name $AZResGroup -Location $AZlocation
# Create the Azure SQL Server
New-AzureRmSqlServer -ResourceGroupName $AZResGroup -Location $AZlocation -ServerName $AZSQLServer -ServerVersion "12.0" -SqlAdministratorCredentials (Get-Credential)
# Allow Azure Services to access the SQL Server
New-AzureRmSqlServerFirewallRule -ResourceGroupName $AZResGroup -ServerName $AZSQLServer -FirewallRuleName "AzureServices" -StartIpAddress "0.0.0.0" -EndIpAddress "0.0.0.0"
# Create Azure SQL Server firewall rule
New-AzureRmSqlServerFirewallRule -ResourceGroupName $AZResGroup -ServerName $AZSQLServer -FirewallRuleName "Lee Home IP" -StartIpAddress "$MyIP" -EndIpAddress "$MyIP"
# Create an Azure SQL Database - Prod
New-AzureRmSqlDatabase -ResourceGroupName $AZResGroup -ServerName $AZSQLServer -DatabaseName $ProdDBName -Edition "Standard"
# Create an Azure SQL Database - Test
New-AzureRmSqlDatabase -ResourceGroupName $AZResGroup -ServerName $AZSQLServer -DatabaseName $TestDBName -Edition "Standard"
# Set the Database tier 
Set-AzureRmSqlDatabase -ResourceGroupName $AZResGroup -DatabaseName $ProdDBName -ServerName $AZSQLServer -Edition "Standard" -RequestedServiceObjectiveName $AzureSQLDBTier
Set-AzureRmSqlDatabase -ResourceGroupName $AZResGroup -DatabaseName $TestDBName -ServerName $AZSQLServer -Edition "Standard" -RequestedServiceObjectiveName $AzureSQLDBTier
write-host "Azure SQL Server and Databases provisioned" 
