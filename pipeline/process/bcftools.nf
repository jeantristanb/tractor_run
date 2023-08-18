
process intersect_pos{
  input :
    tuple val(chro), path(allfile), path(allfileindex), val(outputdir)
  output :
    tuple val(chro), path("$fileintersect")
  publishDir "${outputdir}/intersect/", overwrite:true, mode:'copy'
 script :
  chro=chro.replace('\n','')
  nfile=allfile.size()
  allfile=allfile.join(' ')   
  fileintersect="shared_${chro}"
  """
  ${params.bin_bcftools}  isec -n $nfile -c all `ls *.vcf.gz` > $fileintersect
  """
}

process extractpos{
  input : 
    tuple val(chro), path(vcf), path(vcfindex), path(listpos)
  output :
    tuple val(chro), path("$fileout"), path("${fileout}.csi")
script :
 chro=chro.replace('\n','')
 fileout=vcf.toString().replaceAll(/.gz$/,'').replaceAll(/.vcf$/,'')+'_clean_vcf.gz'
 """
 ${params.bin_bcftools}  view -R $listpos $vcf -O z -o $fileout
 ${params.bin_bcftools}  index $fileout
 """
}


process indexsort_vcf {
  cpus 3
  input :
     tuple val(chro),file(filevcf)
  //publishDir "${params.output_dir}/vcffilt/", overwrite:true, mode:'copy'
  output :
    tuple val(chro), path(fileout), path("${fileout}.*"), emit : out
    tuple path(fileout), path("${fileout}.*"), emit : outnochro
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
   tuple val(chro), path(allfile), path(allfileindex), val(outputdir), val(outputname)
  output :
      tuple val(chro),  path("${finalvcf}"), path("${finalvcf}.csi")
  publishDir "${params.output_dir}/$outputdir/", overwrite:true, mode:'copy'
  script :
   chro=chro.replace('\n','')
   allfile=allfile.join(' ')
   finalvcf=outputname+"_"+chro+".vcf.gz"
   """
   ${params.bin_bcftools}  merge $allfile -m all -O z -o $finalvcf
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


process clean_vcf_phased {
 input : 
   tuple val(chro), path(vcf), path(index), path(ind), path(snp)
 output :
    tuple val(chro), path("$fileout"), path("${fileout}.csi")
 script : 
   fileout=vcf.toString().replaceAll(/.gz$/,'').replaceAll(/.vcf$/,'')+'_clean.vcf.gz'
   keepind=(ind.toString()!='01') ? " --samples-file $ind " : ""
   keeppos=(snp.toString()!='02') ? " -R $snp " : ""
   """
   ${params.bin_bcftools} view $keepind $keeppos  --max-alleles 2 -Oz -o $fileout ${vcf} 
   ${params.bin_bcftools} index $fileout

   """
}

process flip_ref{
 input:
    tuple val(chro), path(vcf), path(index), path(fasta)
 output :
    tuple val(chro),path("$fileout"), path("${fileout}.csi")
 script : 
   fileout=vcf.toString().replaceAll(/.gz$/,'').replaceAll(/.vcf$/,'')+'_fr.vcf.gz'
   """
     ${params.bin_bcftools} +fixref  $vcf -Oz -o $fileout -- -f $fasta -m flip -d  &> $fileout".rep" 
     ${params.bin_bcftools} index $fileout
   """
}

process checkref{
 input:
    tuple val(chro), path(vcf), path(index), path(fasta)
 output :
    tuple val(chro),path("$fileout"), path("${fileout}.csi")
 script :
   fileout=vcf.toString().replaceAll(/.gz$/,'').replaceAll(/.vcf$/,'')+'_fr.vcf.gz'
   """
     ${params.bin_bcftools} +fixref  $vcf -Oz -o $fileout -- -f $fasta -m flip -d  &> $fileout".rep"
     ${params.bin_bcftools} index $fileout
   """
}

