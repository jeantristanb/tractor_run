def strmem(val){
 return val as nextflow.util.MemoryUnit
}

process addchro{
 input :
     file(File)
 output :
     tuple stdout, file(File)
 script :
   """
   head $File |tail -1 |awk '{print \$1}'
   """ 
}


