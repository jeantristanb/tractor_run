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
//params.file_listvcf=''


include {split_by_chro} from './workflow/split_by_chro.nf'
include {addchro} from './process/vcf.nf'
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
     //Channel.fromPath(file(listfilevcf[0], checkIfExists:true).readLines()).collect()
     //println listfilevcf[0]
     list_vcf=[]
     //println listfilevcf
     for(cmt=0;cmt<listfilevcf.size();cmt++){
     list_vcf+=file(listfilevcf[cmt], checkIfExists:true).readLines()
     }
     println listfilevcf
     addchro(Channel.fromPath(list_vcf))
     mergevcf(addchro.out) 
     //vcf_chro=addchro.out.groupTuple()
     //list_vcf1=addchro(Channel.fromPath(file(listfilevcf, checkIfExists:true).readLines(), checkIfExists:true))
     cmt=1
     //   list_vcf2=addchro2(Channel.fromPath(file(listfilevcf[cmt], checkIfExists:true).readLines(), checkIfExists:true))
  }


}

