From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: 2.6.33-rc4 i686 clone function looping (?)
Date: Tue, 19 Jan 2010 09:09:31 -0600
Message-ID: <20100119150931.GA7708@us.ibm.com>
References: <1263852243.4745.363.camel@Mercier.safe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1263852243.4745.363.camel-4BUXZ/Ty1v7iqR6jatDSCA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jean-Marc Pigeon <jmp-4qkeo2rQ0gg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Jean-Marc Pigeon (jmp-4qkeo2rQ0gg@public.gmane.org):
> Hello,
> 
> 	Same physical system and configuration
> 	(small system in 32 Bits i686 mode).
> 	2.6.32.3: 	working A_one.
> 	2.6.33-rc4:	clone call, looping and
> 		    	taking ALL CPU cycle.
> 
> Here is code used.
> ;======================================
> cloneflg=SIGCHLD|__WCLONE;
> cloneflg|=CLONE_NEWNET|CLONE_NEWIPC|CLONE_NEWNS|CLONE_NEWPID|
> CLONE_NEWUTS;
> clonestk=(char *)malloc(STKSIZE)
> ......
> 
> ;--------------------------------------
>   if (argv[0]!=(char *)0) { /*always        */
>         static ARGTYP args;
> 
>         args.mspid=getpid();
>         args.arch=cntarch;
>         args.argc=argc;
>         args.argv=argv;
>         if ((cpid=clone(&doboot,(void *)(clonestk
> +STKSIZE),cloneflg,(void *)&args))<0) {
>           (void) apl_alert(0,"%s, Unable to clone %s container process
> (error=<%s>)",
>                               appname,argv[0],strerror(errno));
> ;======================================
> 
> There is some difference within .config file between
> both kernel I regenerated, but I do not believe they
> are meaningful for the clone/cgroup/veth/bridge functions.
> I can provide config diff if needed.
> 
> Do we have a real problem with 2.6.33-rc4?? or did I missed
> something? could someone confirm trouble with clone call?

I don't see any such problem (on s390).  You leave a large chunk
of your code out of your email, though.  What is STKSIZE?  What
is ARGTYP?  What does doboot do?

The following program verbatim (trying to mimick what I hope your
program looks like) did not give me any problems:

===============================================================
#include <stdio.h>
#include <malloc.h>
#include <signal.h>
#include <wait.h>
#include <sched.h>
#include <errno.h>
#include <linux/sched.h>

#define STKSIZE (4*getpagesize())
#define CLONE_NEWNET		0x40000000	/* New network namespace */

struct arg {
	int a, b;
};

int fn(void *arg)
{
	struct arg *a = arg;
	printf("client a %d b %d\n", a->a, a->b);
}

int main()
{
	struct arg a;
	int cpid;
	long cloneflg=SIGCHLD|__WCLONE;
	void *clonestk;

	cloneflg|=CLONE_NEWNET|CLONE_NEWIPC|CLONE_NEWNS|CLONE_NEWPID|CLONE_NEWUTS;
	clonestk=(char *)malloc(STKSIZE);

	a.a=1; a.b=2;

	if ((cpid=clone(&fn, clonestk+STKSIZE, cloneflg,
			(void *)&a)) < 0)
		printf("Error %d on clone\n", errno);
	printf("parent done\n");
}
===============================================================

-serge
