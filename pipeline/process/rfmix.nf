process run_rfmix {
 input :
   tuple val(chro),path(samplevcf) path(refvcf), path(refind), path(geneticmap), val(outputdir),val(outputname)
 
 output :
   tuple val(chro), path("${outputres}.fb.tsv"),  path("${outputres}.msp.tsv"), path("${outputres}.rfmix.Q"), path("{outputres}.sis.tsv")
 script :
   outputres=outputname+"_"+chro
   """
   params.bin_rfmix -f $samplevcf -m $refvcf -m $refind -g $geneticmap  -o 
   """
}
