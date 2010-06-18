From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Fri, 18 Jun 2010 18:27:34 +0200
Message-ID: <20100618162734.GB7404__36698.1706968092$1276882786$gmane$org@redhat.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com>
	<4C19F0A3.2050707@parallels.com> <m1631hdbdu.fsf@fess.ebiederm.org>
	<20100617213638.GB4182@redhat.com>
	<20100618082738.GE16877@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100618082738.GE16877-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On 06/18, Louis Rilling wrote:
>
> On 17/06/10 23:36 +0200, Oleg Nesterov wrote:
> > On 06/17, Eric W. Biederman wrote:
> > >
> > > The task->children isn't changed until __unhash_process() which runs
> > > after flush_proc_task().
> >
> > Yes. But this is only the current implementation detail.
> > It would be nice to cleanup the code so that EXIT_DEAD tasks are
> > never sit in ->children list.
> >
> > > So we should be able to come up with
> > > a variant of do_wait() that zap_pid_ns_processes can use that does
> > > what we need.
> >
> > See above...
> >
> > Even if we modify do_wait() or add the new variant, how the caller
> > can wait for EXIT_DEAD tasks? I don't think we want to modify
> > release_task() to do __wake_up_parent() or something similar.
>
> Indeed, I was thinking about calling __wake_up_parent() from release_task()
> once parent->children becomes empty.
>
> Not sure about the performance impact though. Maybe some WAIT_NO_CHILDREN flag
> in parent->signal could limit it. But if EXIT_DEAD children are removed from
> ->children before release_task(), I'm afraid that this becomes impossible.

Thinking more, even the current do_wait() from zap_pid_ns_processes()
is not really good. Suppose that some none-init thread is ptraced, then
zap_pid_ns_processes() will hange until the tracer does do_wait() or
exits.

Oleg.
