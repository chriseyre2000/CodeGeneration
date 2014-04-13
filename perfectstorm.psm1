#This is the start of the translation of the perfectstorm codegen tool into powershell

<#
.Synopsis
   Performs an xslt transformation
.DESCRIPTION
   This permits xslt transformations of a supplied xml document. Allows arguments to be passed into the xslt transformation so external parameters can be included.
   By default it will not output the utf header.
.EXAMPLE
   Invoke-Xslt -model "$pwd\model.CodeGen" -template "$pwd\createbatch.xslt" -KeepUTFHeader -outputFilename "$pwd\batch3.txt"
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Invoke-Xslt
{
   Param
   (
        [Switch]$PassThrough =$false,

        [Switch]$KeepUTFHeader, 
        
        [Alias("Source")]
        [Parameter(Mandatory=$true)]
        [string]$Model,
        
        [Alias("Transform")]
        [Parameter(Mandatory=$true)]
        [string]$Template,

        [string]$OutputFilename = $null,

        [System.Collections.Hashtable]$args = $null       
   )

   $transform = New-Object System.Xml.Xsl.XslCompiledTransform
   $transform.Load($template) 
   $argList = New-Object System.Xml.Xsl.XsltArgumentList

   if($args -ne $null)
   {
        foreach($key in $args.Keys)
        {
            $argList.AddParam($key, "", $args[$key])
        }
   }

   $outputMemoryStream = New-Object System.IO.MemoryStream
   $transform.Transform($model, $argList, $outputMemoryStream)

   if(!$KeepUTFHeader)
   {
        $outputMemoryStream = Remove-UnicodeHeader $outputMemoryStream
   }

   if(![string]::IsNullOrEmpty($outputFilename))
   {
        $outputStream = [System.IO.File]::OpenWrite($outputFilename)
        $outputMemoryStream.Position = 0;
        $outputMemoryStream.CopyTo($outputStream);
        $outputMemoryStream.Flush();
   }

   if($PassThrough -or [string]::IsNullOrEmpty($outputFilename))
   {
      return [System.Text.ASCIIEncoding]::UTF8.GetString($outputMemoryStream.ToArray())
   }
}

function Remove-UnicodeHeader([System.IO.MemoryStream]$msInput)
{
    [System.IO.MemoryStream]$result = $msInput;

    if ($msInput.Length > 3)
    {
        [bool]$skipHeader = $true;
        [Byte[]] $check = ( 239, 187, 191 );
        foreach ($i  in 0..2)
        {
            if ($msInput.ReadByte() -ne $check[$i])
            {
                $skipHeader = $false;
                break;
            }
        }

        if ($skipHeader)
        {
            [int]$tailLength = $msInput.Length - 3
            [System.IO.MemoryStream]$ms2 = New-Object "System.IO.MemoryStream" -ArgumentList $msInput.GetBuffer(),3,$tailLength;
            $result = ms2;
        }
    }
    $result.Position = 0
    return $result
}


