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
