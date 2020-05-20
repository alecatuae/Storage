#Pré-Requisitos

##PowerShell
  1. Install-Module -Name VMware.PowerCLI
  2. Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
  3. Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false


# Arquivos
  
  Criacao_vms.ps1  : cria um .csv com UUID, VM, Data de Criacao, Criador, Tipo de Criacao,Resource Pool e Evento;
  
  capacity_vms.ps1 : criar um .csv com dados de performance das VMs;
  
  concat_files.ps1 : concatena o resultado coletados do capacity_vms.ps1.
