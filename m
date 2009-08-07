From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][v4][PATCH 0/7] clone_with_pids() system call
Date: Thu, 6 Aug 2009 23:11:03 -0700
Message-ID: <20090807061103.GA19343__32781.148577533$1249625527$gmane$org@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org



=== NEW CLONE() SYSTEM CALL:

To support application checkpoint/restart, a task must have the same pid it
had when it was checkpointed.  When containers are nested, the tasks within
the containers exist in multiple pid namespaces and hence have multiple pids
to specify during restart.

This patchset implements a new system call, clone_with_pids() that lets a
process specify the pids of the child process.

Patches 1 through 5 are helpers and we believe they are needed for application
restart, regardless of the kernel implementation of application restart.

Patch 7/7 defines a prototype of the new system call.

=== IMPORTANT TODO:

clone() system call has another limitation - all available bits in clone-flags
are in use and any new clone-flag will need a variant of the clone() system
call. 

It appears to make sense to try and extend this new system call to address
this limitation as well. The basic requirements of a new clone system call
could then be summarized as:

	- do everything clone() does today, and
	- give application an ability to choose pids for the child process
	  in all ancestor pid namespaces, and
	- allow more clone_flags

Contstraints:

	- system-calls are restricted to 6 parameters and clone() already
	  takes 5 parameters, any extension to clone() interface would require
	  one or more copy_from_user().

	- does copy_from_user() of a few words have a significant impact on
	  the total cost of clone() ?

Based on these requirements and constraints, we have been exploring a couple
of system call interfaces and appreciate any iput.  

1. =====

	#if 64bit
	#define CLONE_FLAGS_WORDS	1
	#else
	#define CLONE_FLAGS_WORDS	2
	#endif

        struct pid_set {
                int num_pids;
                pid_t *pids;
        };

	typedef struct {
		unsigned long flags[CLONE_FLAGS_WORDS];
	} clone_flags_t;

	int clone_extended(clone_flags_t *flags, void *child_stack, int *unused,
		int *parent_tid, int *child_tid, struct pid_set *pid_set);

	Pros:
		- extendible clone_flags (like sigset_t)

	Cons:
		- copy_from_user() needed on all architectures (we maybe able
		  to play some tricks with 'clone_flags_t' to avoid the copy
		  on 64-bit archtitectures till N_CLONE_FLAGS exceeds 64).

		- Both applications and kernel must use interfaces equivalent
		  to sigsetops(3) to test/set/clear clone flags.
2. ======

	struct clone_info {
		int num_clone_high_words;
		int *flags_high;
		struct pid_set pid_set;
	}

        int clone_extended(int flags_low, void *child_stack, void *unused,
		int *parent_tid, int *child_tid, struct clone_info *clone_info);

	Pros:
		- copy_from_user() needed only for new flags and pid_set

	Cons:
		- splitting the high and low clone-flags is awkward ?


Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
