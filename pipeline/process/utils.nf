def strmem(val){
 return val as nextflow.util.MemoryUnit
}

process addchro{
 input :
     file(File)
 output :
     tuple env(chro), file(File)
 script :
   """
   chro=`head $File |tail -1 |awk '{print \$1}'`
   """ 
}


