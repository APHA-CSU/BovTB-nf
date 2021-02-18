#!/usr/local/bin/python

""" unit_tests.py: 
        This file runs unit tests for the pipeline. 
        Each unit test should be quick to run (ie. milliseconds typically, but certainly less than second) 
        Tests that have a long run time should simplified, mocked, or be a .circleci job.
"""

import unittest
import subprocess
import tempfile
import os
import shutil
import glob
import argparse

class TestPipeline(unittest.TestCase):
    """
        TODO: break this out into individual classes for each nextflow process.
    """
    def setUp(self):
        """
            Create new temporary directory
        """
        self.temp_dir = tempfile.TemporaryDirectory()
        self.temp_dirname = self.temp_dir.__enter__() + '/'

        print('Temp Dir: ' + self.temp_dirname)

    def tearDown(self):
        """
            Cleanup temporary directory.
        """
        self.temp_dir.__exit__(None, None, None)

    def assertBashScript(self, expected_exit_code, cmd):
        """
            Runs a bash script with exit on error (set -e) and throws an exception if the exit code doesn't match the expected 
            
            Inputs: 
                error_code <int>
                cmd <list> The command as a list of strings. eg ['hello-world.bash', '-name', 'Aaron']
        """

        actual_exit_code = subprocess.run(['bash', '-e'] + cmd).returncode
        self.assertEqual(expected_exit_code, actual_exit_code)

    def test_deduplicate(self):
        """
            This introductory unit test asserts the deduplicate process completes on tinyreads without errors.
        """

        # Copy test data
        pair_id = self.temp_dirname + 'tinyreads'

        for file in glob.glob(r'./tests/data/tinyreads/*'):
            shutil.copy(file, self.temp_dirname)

        # Test the script
        self.assertBashScript(0, ['./bin/deduplicate.bash', pair_id])

    def test_mask(self):
        """
            Asserts mask.bash completes without errors when 
            the supplied sam file contains no regions of zero coverage
        """
        pair_id = self.temp_dirname + 'test'

        sam_filepath = './tests/data/tinymatch.sam'
        rpt_mask = './references/Mycbovis-2122-97_LT708304.fas.rpt.regions'

        # Convert to SAM to BAM
        with open(pair_id + '.mapped.sorted.bam', 'w') as f:
            subprocess.call(['samtools', 'view', '-S', '-b', sam_filepath], stdout=f)
       
        # Test
        self.assertBashScript(0, ['./bin/mask.bash', pair_id, rpt_mask])

    def sam_to_bam(self, sam_filepath, bam_filepath):
        # Convert to SAM to BAM
        with open(bam_filepath, 'w') as f:
            subprocess.call(['samtools', 'view', '-S', '-b', sam_filepath], stdout=f)

    def assertReadStats(self, reads_path, name):
        """
            Asserts read stats returns a 0 exit code for the supplied test reads
            TODO: Neaten test code when readStats.bash has input args for all input data
        """
        fastq_1 = reads_path+'_S1_R1_X.fastq.gz'
        fastq_2 = reads_path+'_S1_R2_X.fastq.gz'
        pair_id = self.temp_dirname + name

        # Copy over 
        shutil.copy(fastq_1, self.temp_dirname)
        shutil.copy(fastq_2, self.temp_dirname)

        # Unzip
        fastq_files = glob.glob(self.temp_dirname + '*.gz')
        subprocess.run(['gunzip', '-k'] + fastq_files, cwd=self.temp_dirname)

        fastq_file = fastq_files[0][:-3]

        subprocess.run(['ln', '-s', fastq_file, pair_id+'_uniq_R1.fastq'])
        subprocess.run(['ln', '-s', fastq_file, pair_id+'_uniq_R2.fastq'])
        shutil.copy(fastq_file, pair_id+'_trim_R1.fastq')

        self.sam_to_bam('./tests/data/tinymatch.sam', pair_id+'.mapped.sorted.bam')

        # Test
        self.assertBashScript(0, ['./bin/readStats.bash', pair_id])            

    def test_read_stats_tinyreads(self):
        self.assertReadStats('./tests/data/tinyreads/tinyreads', 'tinyreads')

    def test_read_stats_tinysra(self):
        self.assertReadStats('./tests/data/tinysra/tinysra', 'tinysra')


if __name__ == '__main__':
    unittest.main()
