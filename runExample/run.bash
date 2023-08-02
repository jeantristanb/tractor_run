dirdata=/home
dirdatai=$PWD/tutorial-data/
mkdir -p $dirdatai/log
dldata=0
if [ $dldata -eq 1 ]
then
wget -c https://media.githubusercontent.com/media/Atkinson-Lab/Tractor-tutorial/main/tutorial-data.zip && unzip tutorial-data.zip
fi
balisecheck=1
if [ $balisecheck -eq 1 ]
then
docker run -v $PWD/tutorial-data/:/home/  -it tractor_run   sh -c "shapeit -check \
        --input-vcf $dirdata/ADMIX_COHORT/ASW.unphased.vcf.gz \
        --input-map $dirdata/HAP_REF/chr22.genetic.map.txt \
        --input-ref $dirdata/HAP_REF/chr22.hap.gz $dirdata/HAP_REF/chr22.legend.gz $dirdata/HAP_REF/ALL.sample \
        --output-log $dirdata/log/log"
fi
exit

balisephased=0
if [ $balisephased -eq 1 ]
then

docker run -v $PWD/tutorial-data/:/home/  -it tractor_run   sh -c "shapeit  --input-vcf $dirdata/ADMIX_COHORT/ASW.unphased.vcf.gz \
      --input-map $dirdata/HAP_REF/chr22.genetic.map.txt \
      --input-ref $dirdata/HAP_REF/chr22.hap.gz $dirdata/HAP_REF/chr22.legend.gz $dirdata/HAP_REF/ALL.sample \
      -O $dirdata/ADMIX_COHORT/ASW.phased"""
fi

baliseconvert=0
if [ $baliseconvert -eq 1 ]
then
docker run -v $PWD/tutorial-data/:/home/  -it tractor_run   sh -c "shapeit -convert \
 --input-haps $dirdata/ADMIX_COHORT/ASW.phased\
   --output-vcf $dirdata/ADMIX_COHORT/ASW.phased.vcf"""
fi

if [ ! -f $dirdatai/ADMIX_COHORT/ASW.phased.vcf".gz" ]
then	
docker run -v $PWD/tutorial-data/:/home/  -it tractor_run   sh -c "bgzip $dirdata/ADMIX_COHORT/ASW.phased.vcf "
fi

baliserfmix=0
if [  $baliserfmix -eq 1 ]
then	
docker run -v $PWD/tutorial-data/:/home/  -it tractor_run   sh -c """rfmix -f $dirdata/ADMIX_COHORT/ASW.phased.vcf.gz \
    -r $dirdata/AFR_EUR_REF/YRI_GBR.phased.vcf.gz \
    -m $dirdata/AFR_EUR_REF/YRI_GBR.tsv \
    -g $dirdata/AFR_EUR_REF/chr22.genetic.map.modified.txt \
    -o $dirdata/ADMIX_COHORT/ASW.deconvoluted \
    --chromosome=22
"""
fi

extracttract=0
if [  $extracttract -eq 1 ]
then
docker run -v $PWD/tutorial-data/:/home/  -it tractor_run   sh -c """python3 Tractor/ExtractTracts.py \
      --msp $dirdata/ADMIX_COHORT/ASW.deconvoluted \
      --vcf $dirdata/ADMIX_COHORT/ASW.phased \
      --zipped \
      --num-ancs 2"""
fi


extracttract=0
if [  $extracttract -eq 1 ]
then
docker run -v $PWD/tutorial-data/:/home/  -it tractor_run   sh -c """python3 Tractor/ExtractTracts.py \
      --msp $dirdata/ADMIX_COHORT/ASW.deconvoluted \
      --vcf $dirdata/ADMIX_COHORT/ASW.phased \
      --zipped \
      --num-ancs 2"""
fi
runtract=1
if [  $runtract -eq 1 ]
then
docker run -v $PWD/tutorial-data/:/home/  -it tractor_run   sh -c """python3 Tractor/RunTractor.py --hapdose $dirdata/ADMIX_COHORT/ASW.phased --phe $dirdata/PHENO/Phe.txt --method linear --out $dirdata/SumStats.tsv"""
fi

#docker run -v $PWD/tutorial-data/:/home/  -it tractor_run  "shapeit --help" 
#        --input-vcf $dirdata/ADMIX_COHORT/ASW.unphased.vcf.gz \
#        --input-map $dirdata/HAP_REF/chr22.genetic.map.txt \
#        --input-ref $dirdata/HAP_REF/chr22.hap.gz $dirdata/HAP_REF/chr22.legend.gz $dirdata/HAP_REF/ALL.sample \
#        --output-log $dirdata/"
