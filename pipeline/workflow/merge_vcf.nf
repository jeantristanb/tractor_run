
include {intersect_pos} from '../process/bcftools.nf'
include {indexsort_vcf} from '../process/bcftools.nf'
include {flip_ref} from '../process/bcftools.nf'
include {extractpos} from '../process/bcftools.nf'
include {merge_vcf} from '../process/bcftools.nf'

workflow mergevcf{
  take :
    listvcf
  main :
     indexsort_vcf(listvcf)
     intersect_pos(indexsort_vcf.out.out.groupTuple())
     extractpos(indexsort_vcf.out.out.combine(intersect_pos.out,by: 0)) 
     flip_ref(extractpos.out.combine(channel.fromPath(params.fasta)))
     merge_vcf(flip_ref.out.groupTuple())
   emit :
     vcf= merge_vcf.out

}
