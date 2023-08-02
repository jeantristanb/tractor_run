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


filescript=file(workflow.scriptFile)
projectdir="${filescript.getParent()}"
dummy_dir="${projectdir}/data/"



