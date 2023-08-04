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
   ${params.bin_shapeit} -check \
        --input-vcf $inputchro \
        --input-map $map \
        --input-ref $refhap $reflegend $samplefile \
        --output-log $logout \
        --thread ${params.cpu_shapeit}
   """
}

process shapeit_phase{
 cpus params.cpus_shapeit
 memory { strmem(params.memory_shapeit) + 5.GB * (task.attempt -1) }
 input :
   tuple val(chro),file(filevcf), file(filevcfidx),    file(genet_map) 
 publishDir "${params.output_dir}/shapeit/init/", overwrite:true, mode:'copy'
 output :
   file("${headout}*")
   tuple file("${headout}_i.haps"), file("${headout}_i.sample")
 script :
   headout="${params.output}_phaseshapeit"
   """
   awk '{print \$2" "\$3" "\$4}' $genet_map > tmpmap.txt
   ${params.bin_shapeit} -V $filevcf --input-map tmpmap.txt --input-thr ${params.thr_shapeit} --output-max $headout"_i.haps" $headout"_i.sample" --thread ${params.cpus_other}  --force
   """
}

