#!/bin/bash

home_lcc="lcc07"
backup_dir="${HOME}/kamino_backup/Kamino_Backup"
user="billy"
options="-avz --stats --progress"

cd ${backup_dir}
rsync ${options} ${user}@kamino.chem.auburn.edu:/net/${home_lcc}/${user} .
exit 0
