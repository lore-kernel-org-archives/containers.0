From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [ISSUE] mm: Add a user_ns owner to mm_struct and fix
	ptrace_may_access
Date: Mon, 24 Oct 2016 14:01:30 -0500
Message-ID: <8760oh8tbp.fsf@xmission.com>
References: <20161024105959.GQ1847@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20161024105959.GQ1847-ZmlpmtaulQd+urZeOPWqwQ@public.gmane.org> (Cyrill Gorcunov's message of
	"Mon, 24 Oct 2016 13:59:59 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pavel Emelyanov <xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Andrey Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org


Adding the containers list because that is the general place for these
kinds of discussions.

Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Hi Eric! A few days ago we've noticed that our zombie00 test case started
> failing: https://ci.openvz.org/job/CRIU/view/All/job/CRIU-linux-next/406/console

> ---
> ======================== Run zdtm/static/zombie00 in h =========================
> Start test
> ./zombie00 --pidfile=zombie00.pid --outfile=zombie00.out
> Run criu dump
> Run criu restore
> Send the 15 signal to  30
> Wait for zdtm/static/zombie00(30) to die for 0.100000
> ################ Test zdtm/static/zombie00 FAIL at result check ################
>
> I've narrowed problem down to commit
>
>  | From ce99dd5fd5f600f9f4f0d37bb8847c1cb7c6e4fc Mon Sep 17 00:00:00 2001
>  | From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>  | Date: Thu, 13 Oct 2016 21:23:16 -0500
>  | Subject: [PATCH] mm: Add a user_ns owner to mm_struct and fix
>  |  ptrace_may_access
>  |
>  | During exec dumpable is cleared if the file that is being executed is
>  | not readable by the user executing the file.  A bug in
>  | ptrace_may_access allows reading the file if the executable happens to
>  | enter into a subordinate user namespace (aka clone(CLONE_NEWUSER),
>  | unshare(CLONE_NEWUSER), or setns(fd, CLONE_NEWUSER).
>
> and the reason is that the zombie tasks do not have task::mm and in resut
> we're obtaining -EPERM when trying to read task->exit_code from
> /proc/pid/stat.

Hmm.  As I read the code exit_code should be returned to userspace as a
0.  It does not look to me as if userspace should see an error in
that case.

> Looking into commit I suspect when mm = NULL we've to move back the test
> ptrace_has_cap(__task_cred(task)->user_ns, mode)?

Maybe.

We might want to consider if these lines from do_task_stat make
any sense.

	if (permitted)
		seq_put_decimal_ll(m, " ", task->exit_code);
	else
		seq_puts(m, " 0");

Looking at the code.  Nothing changes behavior except for privileged
tasks looking at processes without an mm.  So yes it may be sane
to tweak that part of the check.

AKA in the in for-next branch the code currenty says:
	mm = task->mm;
	if (!mm ||
	    ((get_dumpable(mm) != SUID_DUMP_USER) &&
	     !ptrace_has_cap(mm->user_ns, mode)))
	    return -EPERM;

And in the case there is no mm there is no way to get
past returning -EPERM.

Looking at why we use ptrace_may_access in the exit_code case
I see a couple of relevant commits.

The commit that added the exit code check:

commit f83ce3e6b02d5e48b3a43b001390e2b58820389d
Author: Jake Edge <jake-T1hC0tSOHrs@public.gmane.org>
Date:   Mon May 4 12:51:14 2009 -0600

    proc: avoid information leaks to non-privileged processes
    
    By using the same test as is used for /proc/pid/maps and /proc/pid/smaps,
    only allow processes that can ptrace() a given process to see information
    that might be used to bypass address space layout randomization (ASLR).
    These include eip, esp, wchan, and start_stack in /proc/pid/stat as well
    as the non-symbolic output from /proc/pid/wchan.
    
    ASLR can be bypassed by sampling eip as shown by the proof-of-concept
    code at http://code.google.com/p/fuzzyaslr/ As part of a presentation
    (http://www.cr0.org/paper/to-jt-linux-alsr-leak.pdf) esp and wchan were
    also noted as possibly usable information leaks as well.  The
    start_stack address also leaks potentially useful information.
    
    Cc: Stable Team <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Signed-off-by: Jake Edge <jake-T1hC0tSOHrs@public.gmane.org>
    Acked-by: Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Acked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>


The change that started protecting start_code/end_code and
generally using these permissions to protect this class of information:

commit 5883f57ca0008ffc93e09cbb9847a1928e50c6f3
Author: Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date:   Wed Mar 23 16:42:53 2011 -0700

    proc: protect mm start_code/end_code in /proc/pid/stat
    
    While mm->start_stack was protected from cross-uid viewing (commit
    f83ce3e6b02d5 ("proc: avoid information leaks to non-privileged
    processes")), the start_code and end_code values were not.  This would
    allow the text location of a PIE binary to leak, defeating ASLR.
    
    Note that the value "1" is used instead of "0" for a protected value since
    "ps", "killall", and likely other readers of /proc/pid/stat, take
    start_code of "0" to mean a kernel thread and will misbehave.  Thanks to
    Brad Spengler for pointing this out.
    
    Addresses CVE-2011-0726
    
    Signed-off-by: Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
    Cc: <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Eugene Teo <eugeneteo-X4ZF2iejbADYtjvyW6yDsg@public.gmane.org>
    Cc: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
    Cc: Brad Spengler <spender-JNS0hek0TMl4qEwOxq4T+Q@public.gmane.org>
    Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>


The commit that added task->exit_code:

commit 5b172087f99189416d5f47fd7ab5e6fb762a9ba3
Author: Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Date:   Thu May 31 16:26:44 2012 -0700

    c/r: procfs: add arg_start/end, env_start/end and exit_code members to /proc/$pid/stat
    
    We would like to have an ability to restore command line arguments and
    program environment pointers but first we need to obtain them somehow.
    Thus we put these values into /proc/$pid/stat.  The exit_code is needed to
    restore zombie tasks.
    
    Signed-off-by: Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
    Acked-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
    Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
    Cc: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
    Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
    Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Cc: Andrew Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
    Cc: Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
    Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
    Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>


Looking at do_task_stat everything else that requires permitted
in do_tack_stat is an address.  exit_code is something else so
I am not at all certain the ptrace_may_access permission check
makes sense.

A process without an mm is fundamentally undumpable so an error should
be returned in any case.  So I don't see any harm in failing
ptrace_may_access in general.  At the same time I can see how not
preserving the existing behavior is problematic.

So I am probably going to tweak the !mm case so that instead of failing
we perform the old capable check in that case.  That seems the mot
certain way to avoid regressions.  With that said, why is exit_code
behind a ptrace_may_access permission check?

Eric
