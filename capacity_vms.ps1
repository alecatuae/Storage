# Lista Maquinas virtuais data de criacao das maquinas virtuais 
$starttime = Get-Date 

#variaveis principais
$vcenter = "vcenter.server"

# Nome do arquivo
$log_dataname = [string]$($starttime.Day)
$log_dataname += [string]"-"
$log_dataname += [string]$($starttime.Month)
$log_dataname += [string]"-"
$log_dataname += [string]$($starttime.year)
$log_dataname += [string]"--"
$log_dataname += [string]$($starttime.hour)
$log_dataname += [string]"-"
$log_dataname += [string]$($starttime.minute)
$log_dataname += [string]"-"
$log_dataname += [string]$($starttime.second)
$arquivocsv = ""
$arquivocsv += [string]"C:\vm_perf_logs\vm_perf_$($log_dataname).csv"


Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue

Write-Host "Conectando ao VCenter"
Connect-VIServer $vcenter -wa 0
Write-Host "Conectado"
Write-Host

#Cria o CSV com o titulo
Write-host  "... Criando o arquivo ($arquivocsv)"
Add-Content $arquivocsv "Data; VM; Mhz; Stat Memoria (KB); Rede (KBps); Stat Volume (GB); Resource Pool; Cluster"


Write-host  "... Preparando consulta"
#lista todas as VMs
$vms = Get-VM | sort Name
#$vms = "AJAX015"

# Preparacao da coleta / Pega os ultimos 10 minutos
$statmhz_prepara = get-stat -Entity "vCenterPrimary" -Stat "cpu.usagemhz.average" -Realtime | Where {$_.Instance -eq ""}
$statmhz_prepara = $statmhz_prepara | Sort Timestamp -Descending
$statmhz_prep = $statmhz_prepara
$statmhz_prep_menos = ($statmhz_prep[0].Timestamp).addMinutes(-10)
$statmhz_prep_mais = ($statmhz_prep[0].Timestamp).addMinutes(10)

Write-host ""


foreach  ($VM in $vms) {
$momento = Get-Date
Write-Host "/Coletando informacoes da VM $($VM)"

Write-Host " -Coletando estatisticas dos Mhz"
$statmhz_coleta = get-stat -Entity $($VM) -Stat "cpu.usagemhz.average" -Realtime | Where {$_.Instance -eq ""}
$statmhz_coleta = $statmhz_coleta | Where {$_.timestamp -ge $statmhz_prep_menos}
$statmhz_coleta = $statmhz_coleta | Where {$_.timestamp -le $statmhz_prep_mais}
$statmhz_coleta = $statmhz_coleta | Sort timestamp -Descending
$statmhz = $statmhz_coleta
$statmhz = $statmhz[0].Value
$statmhz_tt = $statmhz_coleta[0].Timestamp
$statmhz_dd = "$(($statmhz_tt).Day)/$(($statmhz_tt).Month)/$(($statmhz_tt).Year) $(($statmhz_tt).Hour):$(($statmhz_tt).Minute):$(($statmhz_tt).Second)"


Write-Host " -Coletando estatisticas de Memoria"
$statmem_coleta = get-stat -Entity $($VM) -Stat "mem.consumed.average" -Realtime | Sort Timestamp -Descending
$statmem = $statmem_coleta
$statmem = $statmem[0].Value

Write-Host " -Coletando estatisticas de Rede"
$statnet_coleta = get-stat -Entity $($VM) -Stat "net.usage.average" -Realtime | Sort Timestamp -Descending
$statnet = $statnet_coleta
$statnet = $statnet[0].Value

Write-Host " -Coletando total em GB dos discos provisionados"
$totaldisk_coleta =  Get-HardDisk -vm $($VM) |measure -Property CapacityGB -Sum
$totaldisk = $totaldisk_coleta.Sum
$totaldisk = $totaldisk[0]


Write-Host " -Pesquisando Resource Pool"
$respool = Get-ResourcePool -VM $($VM)

Write-Host " -Pesquisando Cluster"
$cluster = Get-Cluster -VM $($VM)

Write-Host " -Escrevendo"
$write = "$statmhz_dd; $VM; $statmhz; $statmem; $statnet; $totaldisk; $respool; $cluster"
Add-Content $arquivocsv $write

Write-Host ""
}

$endtime = Get-Date 
Write-Host "... Fim / Tempo de execucao: $(($endtime-$starttime).totalminutes) minutos"
