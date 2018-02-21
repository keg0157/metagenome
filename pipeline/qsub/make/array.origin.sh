#! /bin/bash
#$ -S /bin/bash
#$ -N {JobName}
#$ -o {LogDir}/{JobName}.stdout.log
#$ -e {LogDir}/{JobName}.stderr.log
#$ -t 1-{NumJobs}

. ~/.bashrc

printf '' > {LogDir}/{JobName}.stdout.log
printf '' > {LogDir}/{JobName}.stderr.log

TaskFile={TaskFile}

get_tasks() {
    NUM_WORKERS=$(expr $SGE_TASK_LAST - $SGE_TASK_FIRST + 1)
    RANK=$SGE_TASK_ID
    echo "NUM_WORKERS=$NUM_WORKERS, RANK=$RANK"
}

run_tasks(){
    sed '/^\s*$/ d' $TaskFile | sed "$RANK~$NUM_WORKERS !d" \
        | xargs -l -I '{}' bash -c '{}'
}

verbose_cmd(){
    echo '-----------------------------------------------------------------'
    echo $@
    echo '-----------------------------------------------------------------'
    $@
}

#verbose_cmd lscpu
verbose_cmd date
verbose_cmd hostname
verbose_cmd get_tasks
verbose_cmd run_tasks
