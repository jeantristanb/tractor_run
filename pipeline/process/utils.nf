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


process merge_2channel{
  input :
     path(file)
     path(file2)
  output :
     tuple path(file), path(file2)
  script :
      """
      echo $file
      """

}
