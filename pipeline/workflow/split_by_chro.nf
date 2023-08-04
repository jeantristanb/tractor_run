include {get_chro} from '../process/vcf.nf'
include {split_bychro} from '../process/vcf.nf'

workflow split_by_chro{
 take :
   vcf
   out
 main :
   get_chro(vcf)
   chro=get_chro.out.flatMap { list_str -> list_str.split() }
   split_bychro(chro.combine(vcf).combine(channel.from(params.output)))
}


