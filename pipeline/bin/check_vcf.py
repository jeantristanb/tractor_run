#!/usr/bin/python3
# coding=utf-8
import argparse
import re
import os
import sys
import glob
import gzip
def GetHeaderVcf(File):
    if readgz :
      VcfRead=gzip.open(File,'rb')
    else :
      VcfRead=open(File)
    Head=[]
    for line in VcfRead:
       if readgz :
          line=line.decode()
       if line[0]=="#" :
         Head.append(line.replace("\n",""))
       else :
         VcfRead.close()
         return Head
    return Head

def checkrefalt(splline) :
  ref=splline[3]
  listalt=splline[4].split(',')
  if ('*' in listalt) or (ref in listalt) or ('0' in listalt) :
    return False
  return True


def parseArguments():
    parser = argparse.ArgumentParser(description='fill in missing bim values')
    parser.add_argument('--out',type=str,required=False, default='stdout')
    parser.add_argument('--vcf',type=str,required=True, default='stdin')
    args = parser.parse_args()
    return args


args = parseArguments()
typehead=args.vcf.split('.')[-1]
readgz=False
if typehead=='gz' or typehead=='gzip':
  readgz=True

headervcf=GetHeaderVcf(args.vcf)
contignb=0
for x in headervcf :
  if "##contig" in x :
     contignb+=1

if contignb ==0: 
 if readgz :
  readvcf=gzip.open(args.vcf)
 else :
  readvcf=open(args.vcf)
 listchr=set([])
 for x in readvcf :
     x=x.decode().split('\t')[0]
     if x[0][0]!='#':
      listchr.add(x[0])
 readvcf.close()
 oldheader=headervcf
 headervcf=headervcf[0:1] 
 headervcf+=["##contig=<ID="+x+">" for x in listchr]
 headervcf+=headervcf[1::] 

###FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
balisegt=False
for x in headervcf :
  if "FORMAT" in x and "ID=GT" in x :
    balisegt=True 

if balisegt==False :
    newlistheader=headervcf[0:1]
    newlistheader+=['##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">']
    newlistheader+=headervcf[1::] 
else :
    newlistheader=headervcf





headervcf=headervcf[-1].split()
NCol=len(headervcf)

writereport=open(args.vcf+'.report', 'w')


if readgz :
  readvcf=gzip.open(args.vcf)
else :
  readvcf=open(args.vcf)

if args.out == 'stdout' :
  writevcf=sys.stdout
else :
  writevcf=open(args.out, 'w')

def getkey(spll) :
  key=spll[0]+'_'+spll[1]
  if spll[3] > spll[4] :
    key=key+'_'+spll[3]+'_'+spll[4]
  else :
    key=key+'_'+spll[4]+'_'+spll[3]
  return key
def getkey2(spll) :
  return spll[0]+'_'+spll[1]

writevcf.write('\n'.join(newlistheader)+'\n')
listkey=set([])
for line in readvcf :
  if readgz :
      line=line.decode()
  if line[0]!="#" :
   spll=line.split()
   key=getkey2(spll)
   if key in listkey :
      writereport.write("\t".join(spll[0:5])+" duplicate chr bp ref alt \n")
   elif len(spll)!=NCol :
      writereport.write("\t".join(spll[0:5])+"not good size\n")
   elif checkrefalt(spll)==False :
        writereport.write(spll[1]+" "+spll[2]+": in ref "+spll[3]+" and alt "+spll[4]+'\n')
   else :
       writevcf.write(line) 
       listkey.add(key)
