
workflow mergevcf{
  take :
    listvcf
  main :
     merge_vcf(listvcf)  


}
