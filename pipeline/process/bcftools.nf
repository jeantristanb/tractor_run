
process intersect_pos{
  input :
    tuple val(chro), path(allfile)
  output :
    tuple val(chro), path(filintersect)
script :
 chro=chro.replace('\n','')
 allfile=allfile.join(' ')   
 fileintersect="shared_${chro}"
 """
 bcftools isec -n~11 -c all `ls *.vcf.gz` > $fileintersect
 """
}

process extractpos{
  input : 
    tuple val(chro), path(vcf), path(vcfindex), path(listpos)
  output :
    tuple val(chro), path(vcf), path("${fileout}.csi")
script :
 chro=chro.replace('\n','')
 fileout=filevcf.toString().replaceAll(/.gz$/,'').replaceAll(/.vcf$/,'')+'_clean_'+chro+'.vcf.gz'
 """
 bcftools view -R $listpos $vcf > $fileout
 bcftools index $fileout
 """
}


process indexsort_vcf {
  cpus 3
  input :
     tuple val(chro),file(filevcf)
  //publishDir "${params.output_dir}/vcffilt/", overwrite:true, mode:'copy'
  output :
     tuple val(chro), path("${fileout}"), path("${fileout}.csi") 
  script :
      chro=chro.replace('\n','')
      fileout=filevcf.toString().replaceAll(/.gz$/,'').replaceAll(/.vcf$/,'')+'_sort_'+chro+'.vcf.gz'
      logfilt="${params.output}_filter.log"
      """
      check_vcf.py --vcf $filevcf | ${params.bin_bcftools} sort | bgzip -c > $fileout
      ${params.bin_bcftools} index $fileout
      """
}

process merge_vcf{
  input :
   tuple val(chro), path(allfile)
  output :
      tuple val(chro),  path("${finalvcf}"), path("${finalvcf}.csi")
  script :
   chro=chro.replace('\n','')
   allfile=allfile.join(' ')
   finalvcf=params.output+"_"+chro+".vcf.gz"
   """
   ${params.bin_bcftools}  merge `ls *.vcf.gz` -m all -O z -o $finalvcf
   ${params.bin_bcftools} index $finalvcf
   """
}

process index_vcf{
 input :
   tuple val(chro), path(vcf)
 output :
   tuple val(chro), path(vcf), path("${vcf}.*"), emit : out
   tuple path(vcf), path("${vcf}.*"), emit : outnochro
 script :
    """
    ${params.bin_bcftools} index $vcf
    """
}

process get_chro {
 input :
   tuple val(chro), path(vcf), path(vcfindex)
 output :
   stdout
 """
 ${params.bin_bcftools}  index -s $vcf | cut -f 1 
 """
}

process split_bychro{
 input :
   tuple val(chro),path(vcf), path(vcfindex),val(out)
 publishDir "${params.output_dir}/splitbychro/", overwrite:true, mode:'copy'
 output :
    tuple val(chro),path("${out}.${chro}.vcf.gz")
 script :
   """
   ${params.bin_bcftools}  view -O z -o ${out}.${chro}.vcf.gz ${vcf} ${chro}
   """
}
