
process shapeit_check{
 cpus params.cpus_shapeit
 memory { strmem(params.memory_shapeit) + 5.GB * (task.attempt -1) }
 input :
  tuple val(chro),path(inputchro), path(map), path(refhap), path(reflegend), path(samplefile)
 output :
   path("$logout*")
 script : 
   logout=params.output+'_'+chro
   """
   shapeit -check \
        --input-vcf $inputchro \
        --input-map $map \
        --input-ref $refhap $reflegend $samplefile \
        --output-log $logout \
        --thread ${params.cpu_shapeit}
   """
}
