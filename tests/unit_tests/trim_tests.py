import unittest
from btb_tests import BtbTests

class TrimTests(BtbTests):
    def test_trim(self):
        """
            This introductory unit test asserts trim.bash completes on tinyreads without errors.
            And produces two fastq files
        """

        # Copy test data
        reads = self.copy_tinyreads()

        # Output Filenames
        outputs = [
            self.temp_dirname + 'out1.fastq',
            self.temp_dirname + 'out2.fastq'
        ]

        # Test the script
        self.assertBashScript(0, ['./bin/trim.bash', reads[0], reads[1], outputs[0], outputs[1]])
        self.assertFileExists(outputs[0])
        self.assertFileExists(outputs[1])

        # TODO: Assert that adapters are indeed trimmed


if __name__ == '__main__':
    unittest.main()