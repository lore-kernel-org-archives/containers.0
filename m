From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH UPDATED 03/10] threadgroup: extend threadgroup_lock()
	to cover exit and exec
Date: Sun, 27 Nov 2011 13:25:58 -0800
Message-ID: <20111127212558.GE4266@google.com>
References: <1320191193-8110-1-git-send-email-tj@kernel.org>
	<1320191193-8110-4-git-send-email-tj@kernel.org>
	<20111124225054.GA14828@google.com>
	<CA+55aFxq1wztMzYhKaY5RHazLBDz4pSXUgiGzTj2wA6EJcDbAw@mail.gmail.com>
	<20111127192155.GB4266@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111127192155.GB4266-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Linus.

On Sun, Nov 27, 2011 at 11:21:55AM -0800, Tejun Heo wrote:
> On Thu, Nov 24, 2011 at 08:02:18PM -0800, Linus Torvalds wrote:
> >  - do you even *need* two separate locks at all? If you extend the
> > threadgroup_fork_lock to cover exec/exit too (and rename it), then why
> > does that separate cred_guard_mutex make sense at all?
> 
> That was mostly choosing the path of least resistance as both locks
> already existed and exec exclusion was added later on, but yeah there
> isn't much to lose by merging those two locks (do_exit nesting inside
> exec will need some care tho).  I'll try to unify the two locks.

Hmmm... I tried this but it seems more difficult than originally
expected.  The biggest obstacle is that we don't have _interruptible
and _killable rwsem ops.

As proposed, what we have is,

* fork and exit paths are read-protected by group_rwsem.  ie. forks
  and exits don't block each other.

* exec path is protected by cred_guard_mutex.  cred_guard_mutex also
  synchronizes parallel exec attempts.  (It's probably better to
  rename it to exec_mutex)

* thread_group_lock() makes the thread group stable by write-locking
  group_rwsem and grabbing cred_guard_mutex.  The former excludes
  forks and exits and the latter exec.

group_rwsem and cred_guard_mutex can be merged by,

* fork and exit paths read-lock group_rwsem as it currently does.

* exec path write-locks group_rwsem.  Note that it'll need to unlock
  in de_thread() while waiting for other threads to exit as exit path
  can't proceed while group_rwsem is write-locked.
  prepare_bprm_creds() should be updated to check signal_pending()
  after acquiring group_rwsem.

  This introduces synchronization between exec and fork/exit paths,
  but I don't think this is something we need to worry about as both
  fork-exec and exit-exec scalabilities don't matter.

* thread_group_lock() write-locks group_rwsem.

The problem is that cred_guard_mutex uses _interruptible/_killable
operations and rwsem doesn't have them, so cred_guard_mutex can't be
easily replaced with write-locking group_rwsem.

If the two locks can't be merged, under the proposed scheme, while not
exactly pretty, both fork/exit and exec paths go through single
locking and only the ones which want stable threadgroup need to grab
both locks, so IMHO it is at least reasonable.

Any better ideas?

Thanks.

-- 
tejun
