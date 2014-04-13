Import-Module $pwd\perfectstorm.psm1 -Force

([xml](get-content $pwd\model.xml)).model.entity.name | % { 
   Invoke-Xslt -Model $pwd\model.xml -Template $pwd\entity.xslt -args @{entity="$_"} -OutputFilename $pwd\$_.cs
}