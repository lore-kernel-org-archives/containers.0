From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH UPDATED 03/10] threadgroup: extend threadgroup_lock() to
	cover exit and exec
Date: Thu, 24 Nov 2011 20:02:18 -0800
Message-ID: <CA+55aFxq1wztMzYhKaY5RHazLBDz4pSXUgiGzTj2wA6EJcDbAw__24461.2601738938$1322193777$gmane$org@mail.gmail.com>
References: <1320191193-8110-1-git-send-email-tj@kernel.org>
	<1320191193-8110-4-git-send-email-tj@kernel.org>
	<20111124225054.GA14828@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111124225054.GA14828-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Nov 24, 2011 at 2:50 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>
> Linus, this is something being scheduled for the next merge window.
> It extends threadgroup locking which cgroup used to do to exclude only
> fork path so that it includes exit and exec paths. =A0threadgroup
> locking is used by cgroup to implement process-scope cgroup migration.
>
> Migration happens in multiple steps, at each of which the matching
> method of each cgroup plugin is called. =A0When a whole process is being
> migrated, methods being called at those different steps expect to see
> consistent image of the thread group.

Ugh.

I see why you want to do this, but I really don't much like some of it.

I've got a few questions:

 - do you even *need* two separate locks at all? If you extend the
threadgroup_fork_lock to cover exec/exit too (and rename it), then why
does that separate cred_guard_mutex make sense at all?

  Taking two locks for the common exit case seems disgusting. What do
the separate locks buy us?

 - could we possible avoid the lock(s) entirely for the
single-threaded case? The fact that ptrace wants to serialize makes me
say "maybe we can't avoid it", but I thought I'd ask. Even if we do
need/want two separate locks, do we really want to take them both for
the case that shouldn't really need even a single one?

Hmm? Simplifying the locking rules is always a good idea, and I think
this seems to make some of it more straightforward, but at the same
time I shudder when I look at some of the patches in the series that
nest locking three locks deep. Ugh.

                 Linus
