#! /bin/bash
set -exu

if [ $# -ne 0 ] ; then libs=($@) ; else
# correctly ordering the dependencies is optional,
# but will cause the loops to iterate fewer times,
# significantly decreasing this script's run time
libs=(glitter restart)
libs+=(ezfork SFork DFork)
libs+=(iSqrt kahan ZePaSt MultiMalloc swap)
libs+=(C-Thread-Pool)
libs+=(StD Array PArray DArr)
libs+=(CAQ CPAQ TSCPAQ CHeap SLL)
libs+=(ezudp EZIO EVIO ThIpe ThrIO ThrEv ThrEll)
libs+=(RW2ChIPC RW2ChIPCStd RW2ChIPCStdExec)
libs+=(ezparse)
libs+=(YACS DOS shell)
#libs+=(solar lunar AVA)
fi

#sudo rm -fv /usr/local/lib/lib*.{so,la,a}*

NC=0
NSB=1

while [ ${#libs[@]} -ne 0 ] ; do
   for N in `seq ${#libs[@]}` ; do

   k=${libs[0]}
   libs=(${libs[@]:1})
   L=(/usr/local/lib/lib${k,,}.{so,a})
   [ ! -e ${L[0]} -o ! -e ${L[0]} ] || continue
   if [ -d $k ] && $NC ; then (
      set -exu
      cd $k
      git reset --hard
      git clean -f -d -x
      git clean -f -d -x
      git pull origin master
   ) ; elif [ -d $k ] ; then
      rm -rf $k
   else
      git clone --depth=1 https://github.com/InnovAnon-Inc/$k
   fi
      
   set -o pipefail
   (
      set -exu
      cd $k
      K=$PWD
      nice -n +20 ./autogen.sh
      if $NSB ; then
         rm -rf   ../build
         mkdir -v ../build
         cd       ../build
      fi
      nice -n +20 $K/configure
      nice -n +20 make
      nice -n +20 make install
   #) |& unbuffer -p tee $k.log && rm -v $k.log || libs+=($k)
   #) |& unbuffer -p tee $k.log && rm -v $k.log || (cat $k.log ; echo $k ; exit 123)
   ) |& unbuffer -p tee $k.log && rm -v $k.log || if [ $# -eq 0 ] ; then libs+=($k) ; else (cat $k.log ; echo $k ; exit 123) ; fi
   set +o pipefail

   done
   [ $N -ne ${#libs[@]} ] || break
done
[ $NSB -ne 0 ] || rm -rf build
