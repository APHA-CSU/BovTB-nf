BIOTOOLS_PATH="/biotools/"


################## DEPENDENCIES ######################

apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openjdk-11-jdk \
    sudo \
    wget \
    make \
    git \
    curl \
    liblzma-dev \
    libz-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libghc-bzlib-prof \
    gcc \
    unzip \
    zlib1g-dev \
    libncurses5-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    python3 \
    python3-numpy \
    python3-pip \
    vim \
    nano \
    bc

# python 
pip3 install biopython pandas
ln -s /usr/bin/python3 /usr/bin/python


################## BIOTOOLS ######################

WORKDIR $BIOTOOLS_PATH

# FastUniq
wget https://sourceforge.net/projects/fastuniq/files/FastUniq-1.1.tar.gz
tar xzf FastUniq-1.1.tar.gz && rm -f FastUniq-1.1.tar.gz
cd FastUniq/source
make
cd ../..
ln -s $BIOTOOLS_PATH/FastUniq/source/fastuniq /usr/local/bin/fastuniq

# Trimmomatic
wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.38.zip
unzip Trimmomatic-0.38.zip
rm -f Trimmomatic-0.38.zip
ln -s $BIOTOOLS_PATH/Trimmomatic-0.38/trimmomatic-0.38.jar /usr/local/bin/trimmomatic.jar

# bwa
git clone https://github.com/lh3/bwa.git
cd bwa
make
cd ..
ln -s $BIOTOOLS_PATH/bwa/bwa /usr/local/bin/bwa

# samtools
wget https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2
tar xjf samtools-1.10.tar.bz2
rm -f samtools-1.10.tar.bz2
cd samtools-1.10
make
sudo make install
cd ..

# use this to install latest commit of bcftools (as opposed to the v1.9 release)
wget https://github.com/samtools/bcftools/releases/download/1.10.2/bcftools-1.10.2.tar.bz2
tar xjf bcftools-1.10.2.tar.bz2
rm -f bcftools-1.10.2.tar.bz2
cd bcftools-1.10.2
make
sudo make install
cd ..

# bedtools
wget https://github.com/arq5x/bedtools2/releases/download/v2.29.0/bedtools-2.29.0.tar.gz
tar xzf bedtools-2.29.0.tar.gz
rm -f bedtools-2.29.0.tar.gz
cd bedtools2
make
cd ..
ln -s $BIOTOOLS_PATH/bedtools2/bin/bedtools /usr/local/bin/bedtools

# kraken2 and associated database
wget http://github.com/DerrickWood/kraken2/archive/v2.0.8-beta.tar.gz
tar xzf v2.0.8-beta.tar.gz
rm -f v2.0.8-beta.tar.gz
cd kraken2-2.0.8-beta
./install_kraken2.sh ../Kraken2
cd ..
ln -s $BIOTOOLS_PATH/Kraken2/kraken2 /usr/local/bin/kraken2

mkdir Kraken2/db

wget https://genome-idx.s3.amazonaws.com/kraken/minikraken2_v1_8GB_201904.tgz
tar xvf minikraken2_v1_8GB_201904.tgz -C Kraken2/db/
rm -f minikraken2_v1_8GB_201904.tgz

# bracken
wget https://github.com/jenniferlu717/Bracken/archive/v2.6.0.tar.gz
tar xzf v2.6.0.tar.gz
rm -f v2.6.0.tar.gz
cd Bracken-2.6.0
sh ./install_bracken.sh ../bracken
cd ..
ln -s $BIOTOOLS_PATH/Bracken-2.6.0/bracken /usr/local/bin/bracken


# Install nextflow.
cat ./install_nextflow.bash | bash
ln -s $PWD/nextflow /usr/local/bin/nextflow

# Install sra-toolkit.
# This was really annoying to install. The only way to get fastq-dump to work was by running vdb-config --i at least once
# vdb-config --i causes weird terminal issues. Workaround is to pipe it to null and ignore the exit code =p
wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.10.8/sratoolkit.2.10.8-ubuntu64.tar.gz
tar -vxzf sratoolkit.2.10.8-ubuntu64.tar.gz
rm sratoolkit.2.10.8-ubuntu64.tar.gz
echo "q" | ./sratoolkit.2.10.8-ubuntu64/bin/vdb-config -i > /dev/null 2>&1; exit 0

ln -s $BIOTOOLS_PATH/sratoolkit.2.10.8-ubuntu64/bin/fasterq-dump /usr/local/bin/fasterq-dump
ln -s $BIOTOOLS_PATH/sratoolkit.2.10.8-ubuntu64/bin/prefetch /usr/local/bin/prefetch

chmod +x ./bin/*
