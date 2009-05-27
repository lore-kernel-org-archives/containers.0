From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 18/38] C/R: core stuff
Date: Thu, 28 May 2009 02:25:47 +0400
Message-ID: <20090527222547.GC8321__44965.6368852176$1243463750$gmane$org@x200.localdomain>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
	<1242968132-1044-18-git-send-email-adobriyan@gmail.com>
	<20090526131644.GA20920@hallyn.com>
	<20090526193503.GB11909@x200.localdomain>
	<4A1DA8FB.3000306@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A1DA8FB.3000306-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, May 27, 2009 at 04:56:27PM -0400, Oren Laadan wrote:
> > Now here goes second version, with prefixes fixed (kstate_") like Ingo
> > suggested and so Linus could look at the code and with C/R code moved
> > close to usual code and with more checks added (which you should have
> > already!) to not restore null selector in %cs for example.
> 
> It is far from perfect. In fact, it's even clearly commented as such,
> and exactly there.  It would have been helpful if you pointed that
> out in a review, or even - god forbid - sent a patch to improve it.

This is ridiculous.

First, you declare that restart(2) should be allowed for anyone(!).
and then send patchset for inclusion in -mm which doesn't even check
if selectors are right!

> But it works, and it lets people play with a more-than-a-toy
> implementation and provide us with important feedback. Oh, and by
> the way, it doesn't require that people use containers to try it out.

Setting up container for playing is not hard:

	CLONE_NEWUTS=y
	CLONE_NEWIPC=y
	CLONE_NEWPID=y
	CLONE_NEWUSER=y
	CLONE_NEWNET=y

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sched.h>
#include <sys/mount.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <fcntl.h>

#define CLONE_NEWNS	0x00020000
#define CLONE_NEWUTS	0x04000000
#define CLONE_NEWIPC	0x08000000
#define CLONE_NEWUSER	0x10000000
#define CLONE_NEWPID	0x20000000
#define CLONE_NEWNET	0x40000000

static int fn(void *_argv)
{
	char **argv = (char **)_argv;

	setsid();
	setpgid(getpid(), getpid());

	execve(argv[0], argv, __environ);
	return 1;
}

int main(int argc, char *argv[])
{
	unsigned long flags = 0;
	int status;
	pid_t pid;
	void *p;

	flags |= CLONE_NEWNS;
	flags |= CLONE_NEWUTS;
	flags |= CLONE_NEWIPC;
	flags |= CLONE_NEWUSER;
	flags |= CLONE_NEWPID;
	flags |= CLONE_NEWNET;

	p = malloc(4 * 4096);
	if (!p)
		return 1;
	argv++;
	pid = clone(fn, p + 4 * 4096, flags, (void *)argv);
	fprintf(stderr, "pid = %d\n", pid);
	if (pid == -1)
		return 1;
	waitpid(pid, &status, __WALL);
	return 0;
}
