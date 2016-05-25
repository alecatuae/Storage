$local = "C:\csv_local_folder"
$arquivos = Get-ChildItem $local

$FOutPut = "concat_output.csv"
Add-Content $FOutPut "Data; VM; Mhz; Stat Memoria (KB); Stat Volume (GB); Resource Pool; Cluster"


foreach ($arquivo in $arquivos) {
$cam_arquivo = $local + "\" + $arquivo.Name
$dado = Import-Csv $cam_arquivo ';'
$Cdado = $dado.Count

    for ($Udado=0;$Udado -lt $Cdado; $Udado++) {
        $Fdata = $dado[$Udado].Data
        $FVM = $dado[$Udado].VM
        $FMhz = $dado[$Udado].Mhz
        $FMem = $dado[$Udado].'Stat Memoria (KB)'
        $FVol = $dado[$Udado].'Stat Volume (GB)'
        $FReP = $dado[$Udado].'Resource Pool'
        $FClu = $dado[$Udado].Cluster
        $FWrite = "$Fdata; $FVM; $FMhz; $FMem; $FVol; $FReP; $FClu"
        Add-Content $FOutPut $FWrite
    } 

#$Fdata = $dado."Data"
#$FVM = $dado."VM"
#$FMhz = $dado."Mhz"
#$FMem = $dado."Stat Memoria (KB)"
#$FVol = $dado."Stat Volume (GB)"
#$FReP = $dado."Resource Pool"
#$FClu = $dado."Cluster"
 
#Add-Content $FOutPut $FWrite
}
