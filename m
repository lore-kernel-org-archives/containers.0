From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] namespaces: introduce sys_hijack (v4)
Date: Wed, 10 Oct 2007 13:32:34 -0500
Message-ID: <20071010183234.GA24770@sergelap.austin.ibm.com>
References: <20071009200928.GA21846@sergelap.austin.ibm.com>
	<470D068F.8050405@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="x+6KMIRAuhnl3hBn"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <470D068F.8050405-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Quoting Cedric Le Goater (clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> Serge E. Hallyn wrote:
> >>From 945fe66259cd0cfdc2fe846287b7821e329a558c Mon Sep 17 00:00:00 2001
> > From: sergeh-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org <hallyn@kernel.(none)>
> > Date: Tue, 9 Oct 2007 08:30:30 -0700
> > Subject: [PATCH] namespaces: introduce sys_hijack (v4)
> > 
> > Move most of do_fork() into a new do_fork_task() which acts on
> > a new argument, task, rather than on current.  do_fork() becomes
> > a call to do_fork_task(current, ...).
> > 
> > Introduce sys_hijack (for x86 only so far).  It is like clone, but
> >  in place of a stack pointer (which is assumed null) it accepts a
> > pid.  The process identified by that pid is the one which is
> > actually cloned.  Some state - include the file table, the signals
> > and sighand (and hence tty), and the ->parent are taken from the
> > calling process.
> 
> hmm, I'm wondering how this is going to work for a process which 
> would have unshared its device (pts) namespace. How are we going 
> to link the pts living in different namespaces if the stdios of the
> hijacked process is using them ? like in the case of a shell, which
> is certainly something we would like to hijacked.
> 
> it looks like a challenge for me. maybe I'm wrong.

Might be a problem, but tough to address that until we actually
have a dev ns or devpts ns and established semantics.

Note the filestruct comes from current, not the hijack target, so
presumably we can work around the tty issue in any case by
keeping an open file across the hijack?

For instance, use the attached modified version of hijack.c
which puts a writeable fd for /tmp/helloworld in fd 5, then
does hijack, then from the resulting shell do

	echo ab >&5

So we should easily be able to work around it.

Or am i missing something?

> > The effect is a sort of namespace enter.  The following program
> > uses sys_hijack to 'enter' all namespaces of the specified pid.
> > For instance in one terminal, do
> > 
> > 	mount -t cgroup -ons /cgroup
> > 	hostname
> > 	  qemu
> > 	ns_exec -u /bin/sh
> > 	  hostname serge
> >           echo $$
> >             1073
> > 	  cat /proc/$$/cgroup
> > 	    ns:/node_1073
> 
> Is there a reason to have the 'node_' prefix ? couldn't we just
> use $pid ? 

Good question.  It's just how the ns-cgroup does it...  If you want to
send in a patch to change that, I'll ack it.

> > In another terminal then do
> > 
> > 	hostname
> > 	  qemu
> > 	cat /proc/$$/cgroup
> > 	  ns:/
> > 	hijack 1073
> > 	  hostname
> > 	    serge
> > 	  cat /proc/$$/cgroup
> > 	    ns:/node_1073
> > 
> > sys_hijack is arch-dependent and is only implemented for i386 so far.
> 
> and worked on my qemu.
> 
> Thanks !

Cool.  Thanks for testing.

-serge

--x+6KMIRAuhnl3hBn
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="duphijack.c"

#define _BSD_SOURCE
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/fcntl.h>
#include <sys/unistd.h>
#include <sched.h>

#ifndef CLONE_NEWUTS
#define CLONE_NEWUTS 0x04000000
#endif

int do_clone_task(void)
{
	execl("/bin/sh", "/bin/sh", NULL);
}

int main(int argc, char *argv[])
{
	int pid;
	int ret;
	int status;
	int fd1, fd2;

	if (argc < 2)
		return 1;
	pid = atoi(argv[1]);

	fd1 = open("/tmp/helloworld", O_RDWR|O_CREAT);
	if (fd1 == -1)
		printf("Error opening /tmp/helloworld\n");
	if (fd1 != 5) {
		dup2(fd1, 5);
		close(fd1);
	}
	write(5, "hi\n", 4);

	ret = syscall(327, SIGCHLD, pid, NULL, NULL);

	if  (ret == 0) {
		return do_clone_task();
	} else if (ret < 0) {
		perror("sys_hijack");
	} else {
		printf("waiting on cloned process %d\n", ret);
		ret = waitpid(ret, &status, __WALL);
		printf("cloned process exited with %d (waitpid ret %d)\n",
				status, ret);
	}

	return ret;
}

--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--x+6KMIRAuhnl3hBn--
