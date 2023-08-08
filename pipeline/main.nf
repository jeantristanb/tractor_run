#!/usr/bin/env nextflow

nextflow.enable.dsl=2
/*
 * Authors       :
 *
 *      Jean-Tristan Brandenburg
 *
 *  On behalf of Cancer Group of Sydney Brenner Institute
 *  2015-2021
 *
 *
 * Description  : Nextflow pipeline for Wits GWAS.
 *
 *(C) University of the Witwatersrand, Johannesburg, 2016-2021
 *This is licensed under the XX licence. See the "LICENSE" file for details
 */

//---- General definitions --------------------------------------------------//

import java.nio.file.Paths;
import sun.nio.fs.UnixPath;
import java.security.MessageDigest;


params.keep_ind_sample=''

params.cpus_shapeit = 5
params.tractor=0

params.ref_tomerge_vcf = '' 
params.ref_tophase_data=''
params.ref_phased=''
params.ref_phased_ind=''
params.ref_keep_ind=''

params.sample_tomerge_vcf = '' 
params.sample_tophase_data=''
params.sample_phased=''
params.sample_file_ind=''
params.sample_keep_ind=''

include {split_by_chro} from './workflow/split_by_chro.nf'
include {addchro as addchro_ref} from './process/vcf.nf'
include {addchro as addchro_sample} from './process/vcf.nf'
include {addchro as addchro_other} from './process/utils.nf'
include {index_vcf as index_vcf_ref} from './process/bcftools.nf'
include {index_vcf as index_vcf_sample} from './process/bcftools.nf'
include {clean_vcf_phased} from './process/bcftools.nf'
include {mergevcf as mergevcf_ref} from './workflow/merge_vcf.nf'
include {phased_data as phased_data_ref} from './workflow/shapeit.nf'
include {phased_data_withref as phased_data_sample} from './workflow/shapeit.nf'
include {get_genetic_map} from './process/shapeit.nf'

filescript=file(workflow.scriptFile)
projectdir="${filescript.getParent()}"
dummy_dir="${projectdir}/data/"

params.split_by_chro=""
workflow {
  if(params.split_by_chro!=''){
     split_by_chro(Channel.fromPath(params.split_by_chro),channel.from(params.output))
  }
  if(params.ref_tomerge_vcf!=''){
     listfilevcf=params.ref_tomerge_vcf.split(',') 
     list_vcf=[]
     for(cmt=0;cmt<listfilevcf.size();cmt++){
     list_vcf+=file(listfilevcf[cmt], checkIfExists:true).readLines()
     }
     addchro_ref(Channel.fromPath(list_vcf, checkIfExists:true))
     mergevcf_ref(addchro_ref.out) 
  }

  if(params.sample_tomerge_vcf!=''){
     listfilevcf=params.sample_tomerge_vcf.split(',')
     list_vcf=[]
     for(cmt=0;cmt<listfilevcf.size();cmt++){
     list_vcf+=file(listfilevcf[cmt], checkIfExists:true).readLines()
     }
     addchro_sample(Channel.fromPath(list_vcf, checkIfExists:true))
     mergevcf_sample(addchro.out)
  }

  listgenetic_map=get_genetic_map(Channel.fromPath(file(params.genetics_map, checkIfExists:true).readLines()))
  if(params.ref_tophase_data!=''){
     if(params.ref_tomerge_vcf==''){
        index_vcf_ref(addchro_ref(Channel.fromPath(file(params.ref_tomerge_vcf, checkIfExists:true).readLines())))
        list_vcf_tophased=index_vcf_ref.out.out
     }else{
        list_vcf_tophased=mergevcf_ref.out
     }
     phased_data_ref(list_vcf_tophased,params.ref_keep_ind, listgenetic_map, channel.from("${params.output_dir}/ref/phased/"), channel.from("ref_phased"))
  }

   if(params.sample_tophase_data!=''){
     if(params.sample_tomerge_vcf==''){
        index_vcf_sample(addchro_sample(Channel.fromPath(file(params.sample_tophase_data, checkIfExists:true).readLines())))
        list_vcf_tophased=index_vcf_sample.out.out
     }else{
        list_vcf_tophased=mergevcf_sample.out
     }
     if(params.ref_tophase_data!=''){
      list_refsample=phased_data_ref.out
     }else{
       addchro_other(Channel.fromPath(file(params.ref_phased, checkIfExists:true).readLines(), checkIfExists:true))
       list_refsample=addchro_other.out.combine(channel.fromPath(params.ref_phased_ind))
       list_refsample.view()
     }
     phased_data_sample(list_vcf_tophased,params.ref_keep_ind, listgenetic_map,list_refsample, channel.from("${params.output_dir}/sample/phased/"), channel.from("sample_phased"))
  }


}

