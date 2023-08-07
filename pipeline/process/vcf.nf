process addchro{
 input :
     path(vcf)
 output :
     tuple stdout, path(vcf)
 script :
      """
      zcat $vcf |grep -v "#" | head -1 |awk '{print \$1}'
      """
}

process split_bychro {
   input :
     tuple val(chro), path(vcf), val(output)
   publishDir "${params.output_dir}/splitbychro/", overwrite:true, mode:'copy'
   output :
     tuple val(chro), path(newvcf), path("${newvcf}.csi")
   script :
      chro=chro.replace('\n','')
      newvcf=params.output+'_'+chro+'.vcf.gz'
      """
      split_by_chro.py --vcf $vcf --chr $chro | bcftools sort | bgzip -c > $newvcf
      bcftools index $newvcf
      """
}

process get_chro {
 input :
   path(vcf)
 output :
   stdout
 """
 zcat $vcf|grep -v "#"|awk '{print \$1}'|uniq|sort|uniq
 """
}

process extract_pos {
  input:
   tuple val(chro),path(vcf), path(vcfindex)
  output :
   tuple val(chro), path(outchrbp)
 script :
  outchrbp=vcf.toString().replaceAll(/.gz$/,'').replaceAll(/.vcf$/,'')+'.pos'
  """
  zcat $vcf |grep -v "#" |awk '{print \$1"\t"\$2}' > $outchrbp
  """
}


