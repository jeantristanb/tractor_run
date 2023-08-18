
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
   tuple val(chro),file(filevcf), file(filevcfidx), file(genet_map),val(outputdir), val(outputname)
 publishDir "${outputdir}/", overwrite:true, mode:'copy'
 output :
   tuple val(chro),path("${headout}.haps"), path("${headout}.sample"),emit : sample
   path("${headout}*"), emit : log
 script :
   headout="${outputname}_${chro}_phaseshapeit"
   """
   ${params.bin_shapeit} -V $filevcf --input-map $genet_map --input-thr ${params.thr_miss_shapeit} --output-max $headout".haps" $headout".sample" --thread ${params.cpus_shapeit}  --force
   """
}



process shapeit_phase_withref{
 cpus params.cpus_shapeit
 memory { strmem(params.memory_shapeit) + 5.GB * (task.attempt -1) }
 input :
   tuple val(chro),file(filevcf), file(filevcfidx), file(genet_map), file(ref), file(ind),val(outputdir), val(outputname)
 publishDir "${outputdir}/", overwrite:true, mode:'copy'
 output :
   tuple val(chro),path("${headout}.haps"), path("${headout}.sample"), emit : sample
   path("${headout}*"), emit : log
 script :
   headout="${outputname}_${chro}_phaseshapeit"
  //shapeit  --input-vcf ADMIX_COHORT/ASW.unphased.vcf.gz \
  //    --input-map HAP_REF/chr22.genetic.map.txt \
  //    --input-ref HAP_REF/chr22.hap.gz HAP_REF/chr22.legend.gz HAP_REF/ALL.sample \
  //    -O ADMIX_COHORT/ASW.phased 
   """
   ${params.bin_shapeit} -V $filevcf --input-map $genet_map  --input-ref $ref $ind --thread ${params.cpus_shapeit}  -O $headout --input-thr ${params.thr_miss_shapeit}
   """
}

process extract_pos{
   input :
     tuple val(chro), file(map)
   output :
     tuple val(chro), file(pos)
   script :
      headout=map.baseName+'.pos'
      """
      sed '1d' $map | awk '{print \$1"\t"\$2}' > $headout
      """
}

process convert_vcf_inhaps{
 input :
    tuple val(chro),path(vcf), val(outputdir), val(outputname)
 publishDir "${outputdir}/", overwrite:true, mode:'copy'
 output :
   tuple val(chro), val("${outputname}.haps"), val("${outputname}.sample")
 script :
  output="${output}_${chro}"
  """
  ${params.bin_shapeit} -convert  --input-vcf $vcf --output-haps $output
  """
}

process convert_haps_invcf {
   input :
     tuple val(chro), path(haps), path(sample), val(outputdir), val(outputname)
   publishDir "${outputdir}/", overwrite:true, mode:'copy'
   output :
     tuple val(chro), path("${vcf}.gz"), path("${vcf}.gz.csi")
   script :
   headbasename=haps.baseName
   vcf="${outputname}_${chro}_phased.vcf"
   """
   ${params.bin_shapeit} -convert --input-haps $headbasename   --output-vcf $vcf
   bgzip $vcf -c > $vcf".gz"
   ${params.bin_bcftools} index $vcf".gz"
   """
}
process addchro {
  input :
      path(haps)
  output :
      tuple stdout ,path(haps)
  script :
    """
    head $haps |tail -1 |awk '{print \$1}'
    """ 
}
