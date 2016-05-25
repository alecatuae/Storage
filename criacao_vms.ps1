# Lista Maquinas virtuais data de criacao das maquinas virtuais 

#variaveis principais
$vcenter = "vcenter.server"
$arquivocsv = "vm_criacao.csv"

Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue

Write-Host "Conectando ao VCenter"
Connect-VIServer $vcenter -wa 0
Write-Host "Conectado"
Write-Host

if(Test-Path $arquivocsv) {
Write-host "limpando o arquivo $($arquivocsv)"
del $($arquivocsv)
}

#Cria o CSV com o titulo
Add-Content $arquivocsv "UUID, VM, Data de Criacao, Criador, Tipo de Criacao,Resource Pool, Evento"


function Get-RPPath{
    param($Object)
    
    $path = $object.Name
    $parent = Get-View $Object.ExtensionData.ResourcePool
    while($parent){
        $path = $parent.Name + "/" + $path
        if($parent.Parent){
            $parent = Get-View $parent.Parent
        }
        else{$parent = $null}
    }
    $path
}

#lista todas as VMs
$vms = ""
$vms = Get-VM | Sort Name

# Pesquisa
foreach  ($VM in $vms) {
Write-Host "/Coletando informacoes da VM $($VM)"


#UUID da VM
$vm_uuid = Get-VM $VM | %{(Get-View $_.Id).config.uuid}
Write-Host "-UUID $($vm_uuid)"


# Criada por Template
$eventos = Get-VIEvent $($VM) -MaxSamples([int]::MaxValue) |Where-Object {$_.FullFormattedMessage -like "Deploying*"} |Select CreatedTime, UserName, FullFormattedMessage
If ($eventos) {
$tipo = "Template"
}

# Criada do inicio
if (!$eventos) {
$eventos = Get-VIEvent $($VM) -MaxSamples([int]::MaxValue) |Where-Object {$_.FullFormattedMessage -like "Created*"} |Select CreatedTime, UserName, FullFormattedMessage
$tipo = "Nova"
}

# Criada por Clone
if (!$eventos) {
$eventos = Get-VIEvent $($VM) -MaxSamples([int]::MaxValue) |Where-Object {$_.FullFormattedMessage -like "Clone*"} |Select CreatedTime, UserName, FullFormattedMessage
$tipo = "Clone"
}

# Criada por Dicovered
if (!$eventos) {
$eventos = Get-VIEvent $($VM) -MaxSamples([int]::MaxValue) |Where-Object {$_.FullFormattedMessage -like "Discovered*"} |Select CreatedTime, UserName, FullFormattedMessage
$tipo = "Discovered"
}

# Criada por Conectada
if (!$eventos) {
$eventos = Get-VIEvent $($VM) -MaxSamples([int]::MaxValue) |Where-Object {$_.FullFormattedMessage -like "Connected*"} |Select CreatedTime, UserName, FullFormattedMessage
$tipo = "Connected"
}


# Origem desconhecida
if (!$eventos) {
$tipo = "Desconhecida"
}

Write-Host "-Tipo $($tipo)"

#Resource Pool
$respool = ""
$respool = Get-RPPath -Object $($VM)
$respool = [string]$respool.Replace("$($VM)", "")

Write-Host "-ResourcePool $($respool)"

    foreach ($event in $eventos) {
    $criada = $event.CreatedTime.toString("dd/MM/yyyy")
    $por = $event.Username
    $evento = $event.FullFormattedMessage
    $write = "$vm_uuid, $VM, $criada, $por, $tipo, $respool, $evento"
    Add-Content $arquivocsv $write
    }

}
