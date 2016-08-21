#!/bin/bash
CPC_HOST=depot@orval.galaxyproject.org
CPC_DIR=/srv/nginx/depot.galaxyproject.org/root/software
rm -f report*.xml
rm -rf CONDA_INSTALL_PATH

rsync -avr . $CPC_HOST:$CPC_DIR/

ssh $CPC_HOST "cd $CPC_DIR && sh upgrade.sh"
ssh $CPC_HOST "cd $CPC_DIR && python bin/process_urls.py urls.tsv > api-tcp.json"
rsync $CPC_HOST:$CPC_DIR/report.xml report-tcp.xml

bash .conda/run.sh

# Update now taht we have a urls-bioconda
rsync -avr urls-bioconda.tsv $CPC_HOST:$CPC_DIR/urls-bioconda.tsv

ssh $CPC_HOST "cd $CPC_DIR && python bin/process_urls.py urls-bioconda.tsv > api-bioconda.json"
rsync $CPC_HOST:$CPC_DIR/report.xml report-bioconda.xml
ssh $CPC_HOST "cd $CPC_DIR && python bin/merge_apis.py api-tcp.json tcp api-bioconda.json bioconda > api.json"
