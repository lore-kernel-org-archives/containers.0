From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: clone_with_pids() library interface
Date: Fri, 5 Jun 2009 19:22:25 -0700
Message-ID: <20090606022225.GA19083@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="9amGYk9869ThD9tj"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Attached are two files -

	cwp.c 		- implements clone_with_pids() library interface
	cwp-test.c	- a simple program to test the interface

There maybe more optimal ways of implementing it though :-)

If it makes sense, will submit as a patch to user-cr tree.

Sukadev

--9amGYk9869ThD9tj
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="cwp.c"


/*
 * Copied from
 *
 * 	http://lkml.indiana.edu/hypermail/linux/kernel/0104.3/0322.html
 *
 * and hacked to suit clone_with_pids() (Sukadev Bhattiprolu)
 */

/*
 * Implementation of Dijkstra's parbegin/parend using clone()
 * Modified from original Linus' clone.c example
 * A proof of concept for academic purposes
 * (c) Francesc Oller 2001, Linus Torvalds
 * Under GPL license
 */

#include <unistd.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sched.h>
#include <errno.h>

#define STACKSIZE 8192
#define __NR_clone_with_pids	335

pid_t clone_with_pids(int clone_flags, long *ptid, long *ctid, void *setp)
{
	long retval;
	long *childsp;
	register long * motherbp __asm__ ("%ebp");

	/*
	 * allocate new stack for child
	 */
	childsp = malloc(STACKSIZE);
	if (!childsp)
		return -1;

	childsp = (long *)(((char *)childsp) + STACKSIZE);
	*--childsp = *(motherbp + 1); /* push return address */
	*--childsp = *motherbp; /* push mother's bp */

	/*
	 * Do clone() system call. We need to do the low-level stuff
	 * entirely in assembly as we're returning with a different
	 * stack in the child process and we couldn't otherwise guarantee
	 * that the program doesn't use the old stack incorrectly.
	 *
	 * Parameters to clone() system call:
	 * %eax - __NR_clone, clone system call number
	 * %ebx - clone_flags, bitmap of cloned data
	 * %ecx - new stack pointer for cloned child
	 *
	 * In this example %ebx is CLONE_VM | CLONE_FS | CLONE_FILES |
	 * CLONE_SIGHAND which shares as much as possible between parent
	 * and child. (We or in the signal to be sent on child termination
	 * into clone_flags: SIGCHLD makes the cloned process work like
	 * a "normal" unix child process)
	 *
	 * The clone() system call returns (in %eax) the pid of the newly
	 * cloned process to the mother, and 0 to the cloned process. If
	 * an error occurs, the return value will be the negative errno.
	 *
	 * Prior to the creation of the child process, we have stored
	 * return adress and caller's bp in child's stack. Child will
	 * restore caller's bp and jmp to the post-clone adress. The
	 * "_exit()" system call at the child's body end will terminate
	 * the child.
	 */

	/* 
	 * The last (sixth) parameter goes into ebp but ebp is needed to
	 * reference local variables. So push values from local variables
	 * into registers before pushing the pid_set into ebp
	 */
	__asm__ (
			"mov %0, %%ebx"
			:
			: "r" (clone_flags)
	  );

	__asm__ (
			"mov %0, %%ecx"
			:
			: "r" (childsp)
	  );

	__asm__ (
			"mov %0, %%edx"
			:
			: "r" (&ptid)
	  );

	__asm__ (
			"mov %0, %%edi"
			:
			: "r" (&ctid)
	  );

	__asm__ (
			"mov %0, %%ebp"
			:
			: "r" (setp)
	  );

	__asm__ __volatile__(
			"int $0x80\n\t" /* Linux/i386 system call */
			"testl %0,%0\n\t" /* check return value */
			"jne 1f\n\t" /* jump if mother */
			"popl %%ebp\n\t" /* restore caller's bp */
			"ret\n" /* jmp to return address */
			"1:\t"
			:"=a" (retval)
			:"0" (__NR_clone_with_pids)
			: "%ebx", "%ecx", "%edx", "%edi", "%ebp"
	);

	if (retval < 0) {
		errno = -retval;
		retval = -1;
	}

	return retval;
}

--9amGYk9869ThD9tj
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="cwp-test.c"

#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>
#include <errno.h>

#define CLONE_NEWPID		0x20000000
#define __NR_gettid		224

/*
 * TODO: getpid() in child returns pid of parent for some reason gettid()
 * 	 returns correct pid (i.e 1 if CLONE_NEWPID or 19799 otherwise)
 */
int gettid()
{
	int rc;

	rc = syscall(__NR_gettid, 0, 0, 0);
	if (rc < 0) {
		printf("rc %d, errno %d\n", rc, errno);
		fflush(stdout);
	}
	return rc;
}

struct target_pid_set {
	int num_pids;
	pid_t *target_pids;
};

extern clone_with_pids(int clone_flags, int *ptid, int *ctid, void *pid_set);

main()
{
	int rc;
	int clone_flags;
	struct target_pid_set pid_set;
	
	int pids[1] = { 19799 };
	
	pid_set.num_pids = 1;
	pid_set.target_pids = &pids[0];

	clone_flags = (CLONE_NEWPID| CLONE_FS | CLONE_FILES | SIGCHLD);

	printf("Parent: Call clone_with_pids() for &pid_set %p\n", &pid_set);

	rc = clone_with_pids(clone_flags, NULL, NULL, &pid_set);
	if (rc == 0) {
		printf("Child: tid %d\n", gettid());
		_exit(0);
	} else if (rc > 0) {
		printf("Parent: child pid %d\n", rc);
		_exit(0);
	} else {
		printf("myclone() failed, rc %d, errno %d\n", rc, errno);
	}
}

--9amGYk9869ThD9tj
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--9amGYk9869ThD9tj--
