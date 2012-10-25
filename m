From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] freezer: change ptrace_stop/do_signal_stop to use
	freezable_schedule()
Date: Thu, 25 Oct 2012 19:34:33 +0200
Message-ID: <20121025173433.GA7650__46941.1298320212$1351186429$gmane$org@redhat.com>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
	<1350426526-14254-3-git-send-email-tj@kernel.org>
	<20121022174404.GA21553@redhat.com>
	<20121022211317.GD5951@atj.dyndns.org>
	<20121023153919.GA16201@redhat.com>
	<20121024185710.GA12182@atj.dyndns.org>
	<20121025163941.GA3801@redhat.com>
	<20121025163959.GB3801@redhat.com>
	<20121025171812.GE11442@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121025171812.GE11442-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/25, Tejun Heo wrote:
>
> Hello, Oleg.
>
> On Thu, Oct 25, 2012 at 06:39:59PM +0200, Oleg Nesterov wrote:
> > Change ptrace_stop() and do_signal_stop() to use freezable_schedule()
> > rather than rely on subsequent try_to_freeze().
> >
> > This allows to remove the task_is_stopped_or_traced() checks from
> > try_to_freeze_tasks() and update_if_frozen(), and this fixes the
> > unlikely race with ptrace_stop(). If the tracee does not schedule()
> > it can miss a freezing condition.
>
> I think it would be great if the description is more detailed.  This
> code path always makes my head spin and I think we can definitely use
> some more guiding in understanding this dang thing. :)

Do you mean describe the race in more details? OK, will do and resend
tomorrow.

> > @@ -2092,7 +2085,7 @@ static bool do_signal_stop(int signr)
> >  		}
> >
> >  		/* Now we don't run again until woken by SIGCONT or SIGKILL */
> > -		schedule();
> > +		freezable_schedule();
>
> This makes me wonder whether we still need try_to_freeze() in
> get_signal_to_deliver() right after the relock: label.  Freezer no
> longer treats STOPPED/TRACED special and both sleeping sites in signal
> deliver path are marked freezable_schedule().  We shouldn't need the
> explicit try_to_freeze(), right?

OOPS.

I'd say this doesn't really matter but yes we can move it up,
get_signal_to_deliver() will be called again.

But! the comment above try_to_freeze() becomes misleading with
this patch, so this really needs v2.

Thanks.

Oleg.
