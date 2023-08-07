
include {strmem} from './utils.nf'
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

process get_genetic_map {
  input :
     path(filemap)
  output :
     tuple env(chro),path(newmap)
  script :
   newmap=filemap.baseName+'_shapeit.txt' 
   """
   awk '{print \$2" "\$3" "\$4}' $filemap > $newmap
   chro=`head $filemap |tail -1 |awk '{print \$1}'`
   """

}

process shapeit_phase{
 cpus params.cpus_shapeit
 memory { strmem(params.memory_shapeit) + 5.GB * (task.attempt -1) }
 input :
   tuple val(chro),file(filevcf), file(filevcfidx), file(genet_map),val(outputname), val(outputdir)
 publishDir "${outputdir}/", overwrite:true, mode:'copy'
 output :
   tuple path("${headout}.haps"), path("${headout}.sample"),emit : sample
   path("${headout}*"), emit : log
 script :
   headout="${output}_${chro}_phaseshapeit"
   """
   ${params.bin_shapeit} -V $filevcf --input-map $genet_map --input-thr ${params.thr_shapeit} --output-max $headout".haps" $headout".sample" --thread ${params.cpus_shapeit}  --force
   """
}



process shapeit_phase_withref{
 cpus params.cpus_shapeit
 memory { strmem(params.memory_shapeit) + 5.GB * (task.attempt -1) }
 input :
   tuple val(chro),file(filevcf), file(filevcfidx), file(genet_map), file(ref), file(ind),val(outputname), val(outputdir)
 publishDir "${outputdir}/", overwrite:true, mode:'copy'
 output :
   tuple path("${headout}.haps"), path("${headout}.sample"), emit : sample
   path("${headout}*"), emit : log
 script :
   headout="${outputname}_${chro}_phaseshapeit"
  //shapeit  --input-vcf ADMIX_COHORT/ASW.unphased.vcf.gz \
  //    --input-map HAP_REF/chr22.genetic.map.txt \
  //    --input-ref HAP_REF/chr22.hap.gz HAP_REF/chr22.legend.gz HAP_REF/ALL.sample \
  //    -O ADMIX_COHORT/ASW.phased 
   """
   ${params.bin_shapeit} -V $filevcf --input-map $genet_map  --input-ref $ref $ind --thread ${params.cpus_shapeit}  -O $headout
   """
}

