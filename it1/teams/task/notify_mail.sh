#!/bin/bash

# Списки лог-файлов и заинтересованных лиц
logPaths=("api.log" "auth.log" "jenkins.log" "data.log")
logEmails=("jay@email" "emma@email" "jon@email" "sophia@email")

# Проверяем логи на предмет наличия сообщений об ошибках
for i in ${!logPaths[@]};
do
  log=${logPaths[$i]}
  stakeholder=${logEmails[$i]}
  numErrors=$( tail -n 100 "$log" | grep "ERROR" | wc -l )

  # Оповещаем заинтересованных лиц при обнаружении более 5 ошибок
  if [[ "$numErrors" -gt 5 ]];
  then
    emailRecipient="$stakeholder"
    emailSubject="WARNING: ${log} showing unusual levels of errors"
    emailBody="${numErrors} errors found in log ${log}"
    echo "$emailBody" | mailx -s "$emailSubject" "$emailRecipient"
  fi
done