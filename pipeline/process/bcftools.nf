
process intersect_pos{
  input :
    tuple val(chro), path(allfile)
  output :
    tuple val(chro), path(filintersect)
script :
 allfile=allfile.join(' ')   
 fileintersect="shared_"
 """
 bcftools isec -n~11 -c all vcfA.vcf.gz vcfB.vcf.gz > 
 """
}

process indexsort_vcf {
  input :
     tuple val(chro),file(filevcf)
  //publishDir "${params.output_dir}/vcffilt/", overwrite:true, mode:'copy'
  output :
     set file("${fileout}.gz"), file("${fileout}.gz.csi") 
  script :
      fileout=filevcf.replaceAll(/.gz$/,'').replaceAll(/.vcf$/,'')+'_sort_'+chro+'.vcf.gz'
      logfilt="${params.output}_filter.log"
      """
      #check_vcf.py --vcf $filevcf --out vcftmp.vcf > $logfilt
      ${params.bin_bcftools} sort  $filevcf | bgzip -c > $fileout".gz"
      ${params.bin_bcftools} index $fileout".gz"
      """
}

process merge_vcf{
  input :
   tuple val(chro), path(allfile)
  output :
      tuple val(chro), path(mergefile)
  script :
   allfile=allfile.join(' ')
   """
   bcftools merge $allfile -m all
   """
}

process split_bychro{
 input :
   tuple tuple(vcf), val(out)
 output :
    file("")
 script :
   """
   bcftools index -s in.vcf.gz | cut -f 1 | while read C; do bcftools view -O z -o ${out}.${C}.vcf.gz in.vcf.gz "${C}" ; done
   """
}
