From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] CGroups: cgroup member list enhancement/fix
Date: Tue, 14 Jul 2009 16:08:41 -0700
Message-ID: <20090714230841.GG5213__36057.4235128753$1247612966$gmane$org@count0.beaverton.ibm.com>
References: <20090705063850.GX11273@balbir.in.ibm.com>
	<6599ad830907101658i13e4046br70377a487dd6b49b@mail.gmail.com>
	<20090713121138.GC5051@balbir.in.ibm.com>
	<6599ad830907130926v7788af12hdcd76e4ccb3ab6de@mail.gmail.com>
	<20090714055638.GI5051@balbir.in.ibm.com>
	<6599ad830907132349u6cf52060t4fafb6637cbe4ed1@mail.gmail.com>
	<20090714071617.GK5051@balbir.in.ibm.com>
	<2f86c2480907141034r5a985cfue9e8fdf64ad28465@mail.gmail.com>
	<6599ad830907141043s1c16d5c9saad9118c210ecef4@mail.gmail.com>
	<6599ad830907141338t794e60admf81807b381c46e41@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830907141338t794e60admf81807b381c46e41-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, libcg-devel <libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jul 14, 2009 at 01:38:30PM -0700, Paul Menage wrote:
> On Tue, Jul 14, 2009 at 10:43 AM, Paul Menage<menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> >
> > I've been trying to think of a way to do that. AFAICS the only way to
> > do that reliably would be to move the call to cgroup_fork() that hooks
> > into the parent's cgroup inside the lock on the group leader's thread
> > list, and move the fork callbacks into cgroup_fork(). (Which would
> > mean that they'd not be able to sleep/fail, etc).
> 
> Currently the only user of the cgroup fork callbacks is the freezer cgroup.
> 
> Matt, if this callback was moved inside tasklist_lock, would that
> present any problems? Given that in other places you call
> freeze_task() from inside other low-level locks like css_set_lock
> (within a cgroup iteration) then hopefully it would be OK.

Yes, it should be OK.

> 
> The only question then would be whether anything between the point
> where cgroup_fork() is currently called, and the point where the new
> thread is added to its thread group list, cares about p->cgroups being
> valid. We can probably flush out any such assumptions by clearing
> tsk->cgroups in dup_task_struct, so that any attempts to reference it
> would immediately oops.

This is harder to verify the correctness of. You're probably right but
I'm not completely convinced yet.

Cheers,
	-Matt
