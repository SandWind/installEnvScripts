addgroup dbs
addgroup gm
addgroup pay
addgroup server
addgroup goscon
useradd -d /longzhu/gamedbs -g dbs  -m -s /bin/bash gamedbs
useradd -d /longzhu/gmtools -g gm  -m -s /bin/bash gmtools
useradd -d /longzhu/goscon -g goscon -m -s /bin/bash goscon
useradd -d /longzhu/payback -g pay -m -s /bin/bash payback
useradd -d /longzhu/server -g server -m -s /bin/bash server
