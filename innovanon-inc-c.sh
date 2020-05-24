#! /bin/bash
set -exu

DIR=$PWD

if command -v sudo ; then
SUDO=sudo
else
SUDO=
fi
[[ -d $DIR/build ]] ||
$SUDO mkdir      $DIR/build
$SUDO chmod a+wt $DIR/build

if [[ $# -ne 0 ]] ; then libs=($@) ; else
# correctly ordering the dependencies is optional,
# but will cause the loops to iterate fewer times,
# significantly decreasing this script's run time
#libs=(glitter restart)
libs=(glitter iSqrt restart)
libs+=(ezfork SFork DFork)
#libs+=(iSqrt kahan ZePaSt MultiMalloc swap)
libs+=(kahan ZePaSt MultiMalloc swap)
libs+=(C-Thread-Pool)
libs+=(StD Array PArray DArr)
libs+=(CAQ CPAQ TSCPAQ CHeap SLL)
libs+=(network ezudp eztcp EZIO EVIO ThIpe ThrIO ThrEv ThrEll)
libs+=(RW2ChIPC RW2ChIPCStd RW2ChIPCStdExec)
libs+=(ezparse)
libs+=(YACS DOS shell)
#libs+=(solar lunar AVA)
fi

#sudo rm -fv /usr/local/lib/lib*.{so,la,a}*

# default is to clobber
NC=${NC:=0}
# default is to not use a separate build directory
# ...because my dependency-tracking hacks broke that feature
NSB=${NSB:=1}
#NSB=${NSB:=0}

while [[ ${#libs[@]} -ne 0 ]] ; do
   for N in `seq ${#libs[@]}` ; do

   k=${libs[0]}
PACKAGE=${k,,}
   libs=(${libs[@]:1})
   L=(/usr/local/lib/lib$PACKAGE.{so,a})
   [[ ! -e ${L[0]} ]] || [[ ! -e ${L[0]} ]] || continue
   if [[ -d $k ]] && [[ $NC -ne 0 ]] ; then (
      set -exu
      cd $k
      git reset --hard
      git clean -f -d -x
      git clean -f -d -x
      git pull origin master
   ) ; else
      rm -rf $k
      git clone --depth=1 https://github.com/InnovAnon-Inc/$k
   fi
      
   set -o pipefail
   (
      set -exu
      cd $k
      K=$PWD

if [[ -z "`git tag`" ]] ; then
  git tag 1.0
  git add .
  git commit -m tagged
  git push origin master
fi
git describe --tags --long

revisioncount=`git log --oneline | wc -l`
projectversion=`git describe --tags --long`
cleanversion=${projectversion%%-*}

#echo "$projectversion-$revisioncount"
#echo "$cleanversion.$revisioncount"
VERSION="$cleanversion.$revisioncount"
#VERSION=1.0.1

rm -rf    $DIR/build/${PACKAGE}/${VERSION}
mkdir -pv $DIR/build/${PACKAGE}/${VERSION}
git archive --format=tar --prefix=${PACKAGE}-${VERSION}/ master | \
xz -c1                                                          > \
          $DIR/build/${PACKAGE}/${VERSION}/${PACKAGE}-${VERSION}.tar.xz
cd        $DIR/build/${PACKAGE}/${VERSION}
tar xf    ${PACKAGE}-${VERSION}.tar.xz
cd        ${PACKAGE}-${VERSION}

./autogen.sh
if [[ $NSB -eq 0 ]] ; then
  rm -rf   $DIR/build-${PACKAGE}
  mkdir -v $DIR/build-${PACKAGE}
  cd       $DIR/build-${PACKAGE}
fi

$DIR/build/${PACKAGE}/${VERSION}/${PACKAGE}-${VERSION}/configure
make

DEBFULLNAME='InnovAnon, Inc. (Ministries)'        \
dh_make                                           \
  --email         InnovAnon-Inc@protonmail.com    \
  --copyright     mit                             \
  --docs                                          \
  --library -y --createorig

sed -i 's/BROKEN/1/g' debian/control
sed -i 'd#^usr/share/pkgconfig/\*$#' debian/${PACKAGE}-dev.install
echo 'usr/lib/*/pkgconfig/*' >> debian/${PACKAGE}-dev.install
echo 'usr/include/*'         >> debian/${PACKAGE}-dev.install
if grep -q '^lib_LTLIBRARIES' src/Makefile.am ; then
echo 'usr/lib/*/*.so*'       >> debian/${PACKAGE}1.install
echo 'usr/lib/*/*.a*'        >> debian/${PACKAGE}1.install
else
sed -i 'd#^usr/lib/\*/lib\*\.so\.\*$#' debian/${PACKAGE}1.install
fi
# TODO weird
! grep -q '^bin_PROGRAMS' src/Makefile.am ||
echo 'usr/bin/*'             >> debian/${PACKAGE}1.install

#debuild                   \
dpkg-buildpackage         \
  --root-command=fakeroot \
  --compression-level=9   \
  --compression=xz        \
  --sign-key=38BBDB7C15E81F38AAF6B7E614F31DFAC260053E

$SUDO dpkg -i ${PACKAGE}_${VERSION}-1_amd64.deb

if [[ $NSB -eq 0 ]] ; then
  rm -rf $DIR/build-${PACKAGE}
fi




#      nice -n +20 ./autogen.sh
#      if [[ $NSB -eq 0 ]] ; then
#         rm -rf   ../build
#         mkdir -v ../build
#         cd       ../build
#      fi
#      nice -n +20 $K/configure
#      nice -n +20 make
#      command -v sudo && nice -n +20 sudo make install || nice -n +20 make install
      #nice -n +20 sudo make install
   #) |& unbuffer -p tee $k.log && rm -v $k.log || libs+=($k)
   #) |& unbuffer -p tee $k.log && rm -v $k.log || (cat $k.log ; echo $k ; exit 123)
   ) |& unbuffer -p tee $k.log && rm -v $k.log || if [[ $# -eq 0 ]] ; then libs+=($k) ; else (cat $k.log ; echo $k ; exit 123) ; fi
   set +o pipefail

   done
   [[ $N -ne ${#libs[@]} ]] || break
done
#[[ $NSB -eq 0 ]] || rm -rf build
