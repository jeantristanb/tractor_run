#!/usr/bin/python3
# coding=utf-8
import argparse
import re
import os
import sys
import glob
import gzip

def getkey(spll) :
  key=spll[0]+'_'+spll[1]
  if spll[3] > spll[4] :
    key=key+'_'+spll[3]+'_'+spll[4]
  else :
    key=key+'_'+spll[4]+'_'+spll[3]
  return key


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
    parser.add_argument('--chr',type=str,required=True)
    args = parser.parse_args()
    return args


args = parseArguments()
typehead=args.vcf.split('.')[-1]
chro=args.chr
readgz=False
if typehead=='gz' or typehead=='gzip':
  readgz=True

headervcf=GetHeaderVcf(args.vcf)
newheadervcf=[]
contignb=0
for x in headervcf :
  if "##contig" in x :
      chrom=x.split('ID=')[1].split(',')[0].split(' ')[0]
      if chrom==chro :
         newheadervcf.append(x)
         contignb=1
  else :
    newheadervcf.append(x)

oldheader=headervcf
if contignb==0: 
 headervcf=headervcf[0:1] 
 headervcf+=["##contig=<ID="+chro+">"]
 headervcf+=oldheader[1::] 

###FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
balisegt=False
cmt=0
for x in headervcf :
  ###FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
  if "FORMAT" in x and "=GT" in x :
    headervcf[cmt]='##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">'
    balisegt=True 
  cmt+=1

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

listkey=set([])

writevcf.write('\n'.join(newlistheader)+'\n')
for line in readvcf :
  if readgz :
      line=line.decode()
  if line[0]!="#" :
   spll=line.split()
   if spll[0]!=chro :
      continue
   key=getkey(spll)
   if key in listkey :
      writereport.write("\t".join(spll[0:5])+" duplicate chr bp ref alt ")
   elif len(spll)!=NCol :
      writereport.write("\t".join(spll[0:5])+"not good size")
   elif checkrefalt(spll)==False :
        writereport.write(spll[1]+" "+spll[2]+": in ref "+spll[3]+" and alt "+spll[4])
   else :
       writevcf.write(line) 
       listkey.add(key)

