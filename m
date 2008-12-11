From: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Subject: Re: Network namespaces tool
Date: Thu, 11 Dec 2008 10:17:22 +0100
Message-ID: <4940DAA2.3020308@bull.net>
References: <7c9d57ea0812110053o4a2753e0m3937ede52955ce4c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000206020606070907080604"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <7c9d57ea0812110053o4a2753e0m3937ede52955ce4c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sargun Dhillon <xbmodder-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------000206020606070907080604
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Sargun Dhillon wrote:
> I'm getting an error when I try to compile the netunshare tool.
> Do you have any ideas to the error:
> 
> netunshare.c:50: error: conflicting types for 'unshare'
> /usr/include/bits/sched.h:78: error: previous declaration of 'unshare' was here

are you using the netunshare.c found there
http://lxc.sourceforge.net/tools/netunshare.c
?

I'm not sure it's up-to-date.
If that's the case, here is an quickly-updated version which shold work 
better for you.

Build it with: gcc -o netunshare -DHAVE_UNSHARE netunshare.c


Also, if you want to play with network namespaces (and containers), you
can try Daniel's excellent liblxc 
(http://sourceforge.net/project/showfiles.php?group_id=163076).

> Additionally, are there any plans to merge in sysfs support into the kernel?

This is a question for Eric I guess.
I don't know what are his plan with the sysfs issue. There are some
stuff to fix in sysfs first, and I don't know if there have been any
progress on this front yet.


Benjamin




> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com

--------------000206020606070907080604
Content-Type: text/x-csrc;
 name="netunshare.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netunshare.c"

#include <stdio.h>
#include <stdlib.h>
#include <sched.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <libgen.h>

#include <linux/unistd.h>

#ifndef _syscall0
#define _syscall0(type,name) \
type name(void) \
{\
        return syscall(__NR_##name);\
}
#endif

#ifndef _syscall1
#define _syscall1(type,name,type1,arg1) \
type name(type1 arg1) \
{\
        return syscall(__NR_##name, arg1);\
}
#endif

#ifndef HAVE_UNSHARE

#if __i386__
#    define __NR_unshare 310
#elif __x86_64__
#    define __NR_unshare 272
#elif __ia64__
#    define __NR_unshare 1296
#elif __s390x__
#    define __NR_unshare 303
#elif __powerpc__
#    define __NR_unshare 282
#else
#    error "Architecture not supported"
#endif

#ifndef unshare
static inline _syscall1 (int,  unshare, unsigned long, flags)
#endif

#endif /* HAVE_UNSHARE */

#ifndef CLONE_NEWNET
#define CLONE_NEWNET		0x40000000
#endif

static const char* procname;

static void usage(const char *name)
{
	printf("usage: %s [-h] [command [arg ...]]\n", name);
	printf("\n");
	printf("  -h		this message\n");
	printf("\n");
	exit(1);
}

int main(int argc, char *argv[])
{	
	int c;
	unsigned long flags = CLONE_NEWNET;

	procname = basename(argv[0]);

	while ((c = getopt(argc, argv, "+muiUnNphI:")) != EOF) {
		switch (c) {
		case 'h':
		default:
			usage(procname);
		}
	};
    
	argv = &argv[optind];
	argc = argc - optind;	
	
	if (unshare(flags) == -1) {
		perror("unshare");
		return 1;
	} 
	
	if (argc) {
		execve(argv[0], argv, __environ);
		perror("execve");
		return 1;
	}

	return 0;
}


--------------000206020606070907080604
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--------------000206020606070907080604--
