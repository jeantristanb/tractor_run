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
###FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
balise=False
for x in headervcf :
  if "FORMAT" in x and "ID=GT" in x :
    balise=True 

if balise==False :
    newlistheader=headervcf[0:3]
    newlistheader+=['##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">']
    newlistheader+=headervcf[3::] 
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

writevcf.write('\n'.join(newlistheader)+'\n')
for line in readvcf :
  if readgz :
      line=line.decode()
  if line[0]!="#" :
   spll=line.split()
   if len(spll)!=NCol :
      writereport.write("\t".join(spll[0:5])+"not good size")
   elif checkrefalt(spll)==False :
        writereport.write(spll[1]+" "+spll[2]+": in ref "+spll[3]+" and alt "+spll[4])
   else :
       writevcf.write(line) 
