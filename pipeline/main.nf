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

params.merge_vcf = '' 
params.keep_ind=''
params.phased_data=''
//params.file_listvcf=''


include {split_by_chro} from './workflow/split_by_chro.nf'
include {addchro} from './process/vcf.nf'
include {index_vcf} from './process/bcftools.nf'
include {clean_ind} from './process/bcftools.nf'
include {mergevcf} from './workflow/merge_vcf.nf'

filescript=file(workflow.scriptFile)
projectdir="${filescript.getParent()}"
dummy_dir="${projectdir}/data/"

params.split_by_chro=""
workflow {
  if(params.split_by_chro!=''){
     split_by_chro(Channel.fromPath(params.split_by_chro),channel.from(params.output))
  }
  if(params.merge_vcf!=''){
     listfilevcf=params.merge_vcf.split(',') 
     list_vcf=[]
     for(cmt=0;cmt<listfilevcf.size();cmt++){
     list_vcf+=file(listfilevcf[cmt], checkIfExists:true).readLines()
     }
     addchro(Channel.fromPath(list_vcf, checkIfExists:true))
     mergevcf(addchro.out) 
     cmt=1
  }
  if(params.phased_data!=''){
     if(params.merge_vcf==''){
        index_vcf(addchro(Channel.fromPath(file(listfilevcf[cmt], checkIfExists:true).readLines())))
        list_vcf_tophased=index_vcf.out.out
     }else{
        list_vcf_tophased=mergevcf.out
     }
   if(params.keep_ind){

   }else{
    list_vcf_clean=list_vcf_tophased
   }
   shapeit_phase(list_vcf_tophased.combine(Channel.fromPath(params.genetics_map)))
  }

}

