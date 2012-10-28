From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 1/1] freezer: change ptrace_stop/do_signal_stop to
	use freezable_schedule()
Date: Sun, 28 Oct 2012 14:45:33 +0100
Message-ID: <20121028134533.GA30847@redhat.com>
References: <20121023153919.GA16201@redhat.com>
	<20121024185710.GA12182@atj.dyndns.org>
	<20121025163941.GA3801@redhat.com>
	<20121025163959.GB3801@redhat.com>
	<20121025171812.GE11442@htj.dyndns.org>
	<20121025173433.GA7650@redhat.com>
	<20121025173632.GI11442@htj.dyndns.org>
	<20121026174545.GA21639@redhat.com>
	<20121026174606.GB21639@redhat.com>
	<1351376558.21585.1.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1351376558.21585.1.camel-nDn/Rdv9kqW9Jme8/bJn5UCKIB8iOfG2tUK59QYPAWc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/27, Ben Hutchings wrote:
>
> On Fri, 2012-10-26 at 19:46 +0200, Oleg Nesterov wrote:
> > try_to_freeze_tasks() and cgroup_freezer rely on scheduler locks
> > to ensure that a task doing STOPPED/TRACED -> RUNNING transition
> > can't escape freezing. This mostly works, but ptrace_stop() does
> > not necessarily call schedule(), it can change task->state back to
> > RUNNING and check freezing() without any lock/barrier in between.
> >
> > We could add the necessary barrier, but this patch changes
> > ptrace_stop() and do_signal_stop() to use freezable_schedule().
> > This fixes the race, freezer_count() and freezer_should_skip()
> > carefully avoid the race.
> >
> > And this simplifies the code, try_to_freeze_tasks/update_if_frozen
> > no longer need to use task_is_stopped_or_traced() checks with the
> > non trivial assumptions. We can rely on the mechanism which was
> > specially designed to mark the sleeping task as "frozen enough".
> >
> > v2: As Tejun pointed out, we can also change get_signal_to_deliver()
> > and move try_to_freeze() up before 'relock' label.
> >
> > Signed-off-by: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> [...]
>
> This is not the correct way to submit a change to stable.  Please see
> Documentation/stable_kernel_rules.txt

Sorry for confusion, it is not for stable@, it was cc'ed by mistake.

Oleg.
