
include {intersect_pos} from '../process/bcftools.nf'
include {indexsort_vcf} from '../process/bcftools.nf'
include {extractpos} from '../process/bcftools.nf'
include {merge_vcf} from '../process/bcftools.nf'

workflow mergevcf{
  take :
    listvcf
  main :
     indexsort_vcf(listvcf)
     intersect_pos(indexsort_vcf.out.groupTuple())
     extractpos(listvcf.combine(intersect_pos.out,by: 0))
     merge_vcf(extractpos.out.groupTuple())

}