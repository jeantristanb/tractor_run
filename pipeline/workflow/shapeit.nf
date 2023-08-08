
include {clean_vcf_phased} from '../process/bcftools.nf'
include {shapeit_phase} from '../process/shapeit.nf'
include {shapeit_phase_withref} from '../process/shapeit.nf'
include {extract_pos} from '../process/shapeit.nf'
include {addchro} from '../process/utils.nf'

workflow phased_data{
  take :
    list_vcf
    keep_ind
    listgenetic_map
    output
    outputdir
  main :
     if(keep_ind=='')keep_ind=channel.fromPath('01')
     else keep_ind=channel.fromPath(keep_ind)
     clean_vcf_phased(list_vcf.combine(keep_ind).combine(channel.fromPath('02')))
     shapeit_phase(clean_vcf_phased.out.combine(listgenetic_map, by: 0).combine(output).combine(outputdir))
 emit:
     phased=shapeit_phase.out.sample

}



workflow phased_data_withref{
  take :
    list_vcf
    keep_ind
    listgenetic_map
    ref
    output
    outputdir
  main :
     if(keep_ind=='')keep_ind=channel.fromPath('01')
     else keep_ind=channel.fromPath(keep_ind)
     extract_pos(ref)
     clean_vcf_phased(list_vcf.combine(keep_ind).combine(extract_pos.out, by:0))
     clean_vcf_phased.out.view()
     listgenetic_map.view()
     shapeit_phase_withref(clean_vcf_phased.out.combine(listgenetic_map, by: 0).combine(ref, by:0).combine(output).combine(outputdir))
 emit:
     phased=shapeit_phase_withref.out.sample
}


