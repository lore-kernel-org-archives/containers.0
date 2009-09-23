From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] restart: add switch '--self' for self-restart
Date: Wed, 23 Sep 2009 03:12:08 -0400
Message-ID: <4AB9CA48.5000402@librato.com>
References: <1253664996-3439-1-git-send-email-orenl@librato.com>
	<20090923042805.GC11296@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090923042805.GC11296-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
>> There is no reason to keep a separate program for self-restart.
>> Get rid of self_restart.c
> 
> Hmm?  But you also took self_checkpoint.c out of PROGS in Makefile...

self_checkpoint.c is an example of how to do self-checkpoint.

It isn't a utility, so I see no point in compiling it....

> 
> Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
>> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
>> ---
>>  Makefile       |    7 +++----
>>  restart.c      |   25 +++++++++++++++++++++++--
>>  self_restart.c |   35 -----------------------------------
>>  3 files changed, 26 insertions(+), 41 deletions(-)
>>  delete mode 100644 self_restart.c
>>
>> diff --git a/Makefile b/Makefile
>> index 830e2c8..7f5cb27 100644
>> --- a/Makefile
>> +++ b/Makefile
>> @@ -35,7 +35,7 @@ CFLAGS += -g $(WARNS) $(CKPT_INCLUDE) $(DEBUG)
>>  # install dir
>>  INSTALL_DIR = /bin
>>
>> -PROGS =	self_checkpoint self_restart checkpoint restart ckptinfo
>> +PROGS =	checkpoint restart ckptinfo
>>
>>  # other cleanup
>>  OTHER = ckptinfo_types.c
>> @@ -43,7 +43,6 @@ OTHER = ckptinfo_types.c
>>  LDLIBS = -lm
>>
>>  all: $(PROGS)
>> -	echo $(SUBARCH)
>>  	@make -C test
>>
>>  # restart needs to be thread-safe
>> @@ -68,8 +67,8 @@ ckptinfo_types.c: $(CKPT_HEADERS) ckptinfo.py
>>  	@cat $(CKPT_HEADERS) | ./ckptinfo.py > ckptinfo_types.c
>>
>>  install:
>> -	@echo /usr/bin/install -m 755 checkpoint restart self_restart ckptinfo $(INSTALL_DIR)
>> -	@/usr/bin/install -m 755 checkpoint restart self_restart ckptinfo $(INSTALL_DIR)
>> +	@echo /usr/bin/install -m 755 checkpoint restart ckptinfo $(INSTALL_DIR)
>> +	@/usr/bin/install -m 755 checkpoint restart ckptinfo $(INSTALL_DIR)
>>
>>  clean:
>>  	@rm -f $(PROGS) $(OTHER) *~ *.o
>> diff --git a/restart.c b/restart.c
>> index 600a282..c0d52a5 100644
>> --- a/restart.c
>> +++ b/restart.c
>> @@ -63,6 +63,7 @@ static char usage_str[] =
>>  "  -p,--pidns            create a new pid namspace (default with --pids)\n"
>>  "  -P,--no-pidns         do not create a new pid namespace (default)\n"
>>  "     --pids             restore original pids (default with --pidns)\n"
>> +"     --self             restart a single task, usually from self-checkpoint\n"
>>  "  -r,--root=ROOT        restart under the directory ROOT instead of current\n"
>>  "     --signal=SIG       send SIG to root task on SIGINT (default: SIGKILL\n"
>>  "                        to container root, SIGINT otherwise)\n"
>> @@ -335,6 +336,7 @@ struct pid_swap {
>>  };
>>
>>  struct args {
>> +	int self;
>>  	int pids;
>>  	int pidns;
>>  	int no_pidns;
>> @@ -372,6 +374,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
>>  		{ "pidns",	no_argument,		NULL, 'p' },
>>  		{ "no-pidns",	no_argument,		NULL, 'P' },
>>  		{ "pids",	no_argument,		NULL, 3 },
>> +		{ "self",	no_argument,		NULL, 6},
>>  		{ "signal",	required_argument,	NULL, 4 },
>>  		{ "inspect",	no_argument,		NULL, 5 },
>>  		{ "input",	required_argument,		NULL, 'i' },
>> @@ -417,6 +420,9 @@ static void parse_args(struct args *args, int argc, char *argv[])
>>  		case 'P':
>>  			args->no_pidns = 1;
>>  			break;
>> +		case 6:  /* --self */
>> +			args->self = 1;
>> +			break;
>>  		case 4:  /* --signal */
>>  			sig = str2sig(optarg);
>>  			if (sig < 0)
>> @@ -488,6 +494,13 @@ static void parse_args(struct args *args, int argc, char *argv[])
>>  		exit(1);
>>  	}
>>  #endif
>> +
>> +	if (args->self &&
>> +	    (args->pids || args->pidns || args->no_pidns || args->wait ||
>> +	     args->show_status || args->copy_status || args->freezer)) {
>> +		printf("Invalid mix of --self with multiprocess options\n");
>> +		exit(1);
>> +	}
>>  }
>>
>>  static void report_exit_status(int status, char *str, int debug)
>> @@ -650,14 +663,22 @@ int main(int argc, char *argv[])
>>  	if (args.freezer && freezer_prepare(&ctx) < 0)
>>  		exit(1);
>>
>> -	setpgrp();
>> -
>>  	/* chroot ? */
>>  	if (args.root && chroot(args.root) < 0) {
>>  		perror("chroot");
>>  		exit(1);
>>  	}
>>
>> +	/* self-restart ends here: */
>> +	if (args.self) {
>> +		restart(getpid(), STDIN_FILENO, RESTART_TASKSELF);
>> +		/* reach here if restart(2) failed ! */
>> +		perror("restart");
>> +		exit(1);
>> +	}
>> +
>> +	setpgrp();
>> +
>>  	ret = ckpt_read_header(&ctx);
>>  	if (ret < 0) {
>>  		perror("read c/r header");
>> diff --git a/self_restart.c b/self_restart.c
>> deleted file mode 100644
>> index b0fbaab..0000000
>> --- a/self_restart.c
>> +++ /dev/null
>> @@ -1,35 +0,0 @@
>> -/*
>> - *  self_restart.c: restart a single process
>> - *
>> - *  Copyright (C) 2008 Oren Laadan
>> - *
>> - *  This file is subject to the terms and conditions of the GNU General Public
>> - *  License.  See the file COPYING in the main directory of the Linux
>> - *  distribution for more details.
>> - */
>> -
>> -#define _GNU_SOURCE        /* or _BSD_SOURCE or _SVID_SOURCE */
>> -
>> -#include <stdio.h>
>> -#include <stdlib.h>
>> -#include <errno.h>
>> -#include <fcntl.h>
>> -#include <unistd.h>
>> -#include <asm/unistd.h>
>> -#include <sys/syscall.h>
>> -
>> -#include <linux/checkpoint.h>
>> -
>> -int main(int argc, char *argv[])
>> -{
>> -	pid_t pid = getpid();
>> -	int ret;
>> -
>> -	ret = syscall(__NR_restart, pid, STDIN_FILENO, RESTART_TASKSELF);
>> -	if (ret < 0)
>> -		perror("restart");
>> -
>> -	printf("should not reach here !\n");
>> -
>> -	return 0;
>> -}
>> -- 
>> 1.6.0.4
>>
>> _______________________________________________
>> Containers mailing list
>> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>> https://lists.linux-foundation.org/mailman/listinfo/containers
