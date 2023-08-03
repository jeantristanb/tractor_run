include {get_chro} from '../process/bcftools.nf'
include {index_vcf} from '../process/bcftools.nf'
include {split_bychro} from '../process/bcftools.nf'

workflow split_by_chro{
 take :
   vcf
   out
 main :
   index_vcf(channel.from("1").combine(vcf))
   get_chro(index_vcf.out.out)
   chro=get_chro.out.flatMap { list_str -> list_str.split() }
   split_bychro(chro.combine(index_vcf.out.outnochro).combine(channel.from(params.output)))
}
