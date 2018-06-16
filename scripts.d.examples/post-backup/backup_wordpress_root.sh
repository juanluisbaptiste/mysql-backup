#!/bin/bash
# Backup a WordPress site (db + files).
WWW_ROOT=${WWW_ROOT:-"/var/www/html/wp-content"}
SERVICE_NAME=${SERVICE_NAME:-"wordpress"}

if [[ -n "$DB_DUMP_DEBUG" ]]; then
  set -x
fi

NOW=$(date +"%Y-%m-%d-%H_%M")

if [ -e ${DUMPFILE} ];
then
  backups_dir=$(dirname ${DUMPFILE})
  tmp_dir=$(mktemp -d)
  wordpress_files="${SERVICE_NAME}-${NOW}-files.tar.gz"
  wordpress_full_backup="${SERVICE_NAME}-${NOW}-full.tar.gz"
  restore_dir="/restore"
  mkdir ${restore_dir}

  echo "Backing up ${WWW_ROOT} directory"
  cd /${tmp_dir}
  tar zcf ${wordpress_files} -C ${tmp_dir} ${WWW_ROOT}
  [[ $? -gt 0 ]] && echo "Could not compress files from ${SERVICE_NAME} directory!" && exit 1

  echo "Copying SQL dump file"
  cp ${DUMPFILE} ${tmp_dir}
  [[ $? -gt 0 ]] && echo "Could not copy SQL dump!" && exit 1

  echo "Creating new tarball"
  #cd ${restore_dir}
  tar zcf ${restore_dir}/${wordpress_full_backup} *
  [[ $? -gt 0 ]] && echo "Could not create ${SERVICE_NAME} full backup file!" && exit 1

  echo "Moving new backup file to: ${DUMPDIR}"
  mv ${restore_dir}/${wordpress_full_backup} ${DUMPDIR}
  [[ $? -gt 0 ]] && echo "Could not move the backup file to ${DUMPDIR}!" && exit 1

  #cleanup
  rm -fr ${tmp_dir}
else
  echo "ERROR: Backup file ${DUMPFILE} does not exist!"
fi
