############################################################################################################
# Conteudo: Script para criação de Device Collection; Janela de Mautenção; Deploy de Patch
# Gerencia: Gerencia de Automação e Implantação de Tecnologia
# Data:  14/11/2020
# Versao: 1.0
############################################################################################################

# Incluir os servidores um em cada linha no arquivo "D:\work\ServersPatch.txt"
# Importar o módulo de comandos powershell para System Center Configuration Manager
import-module "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager\ConfigurationManager.psd1"

# Configura o site e efetua a conexão
New-PSDrive -Name "NDC - Novo DataCenter" -PSProvider "AdminUI.PS.Provider\CMSite" -Root "SCMCOR00101P.corporate.int" -Description "Primary site"
Set-Location NDC:

$Mudanca = Read-Host "Qual o número da Mudança?"
$Data = Read-host "Qual a data da mudança? MM/DD/YYYY"
New-CMDeviceCollection -Name $Mudanca -LimitingCollectionName "All Systems"
Get-Content "D:\work\ServersPatch.txt" | foreach { Add-CMDeviceCollectionDirectMembershipRule -CollectionName $Mudanca -ResourceID (Get-CMDevice -Name $_).ResourceID }

# Alterar a data e hora de início e fim da janela de manutenção. Formato AM/PM e MM/DD/YYYY
$MaintenanceWindowsSchedule = New-CMSchedule -Nonrecurring -Start "$Data 09:00AM" -End "$Data 12:30PM"
New-CMMaintenanceWindow -CollectionName $Mudanca -Name $Mudanca -Schedule $MaintenanceWindowsSchedule

# Alterar a data e hora de Deploy. Formato AM e PM e MM/DD/YYYY
New-CMSoftwareUpdateDeployment -DeploymentName $Mudanca -SoftwareUpdateGroupName “Patch Management 2020 - Ciclo 1 (W2K8,W2K12,W2K16)” -CollectionName $Mudanca -DeploymentType Required -VerbosityLevel AllMessages -AvailableDateTime "$Data 07:00AM" -DeadlineDateTime "$Data 08:00AM" -UserNotification DisplaySoftwareCenterOnly -SoftwareInstallation $False  -AllowRestart $False  -RestartServer $False