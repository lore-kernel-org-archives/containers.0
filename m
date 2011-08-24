From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHSET] cgroup: introduce cgroup_taskset and consolidate
	subsys methods
Date: Wed, 24 Aug 2011 09:49:59 +0200
Message-ID: <20110824074959.GA14170__14622.6289718927$1314172450$gmane$org@htj.dyndns.org>
References: <1314138000-2049-1-git-send-email-tj@kernel.org>
	<20110824011428.GC23979@somewhere>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110824011428.GC23979@somewhere>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Frederic.

On Wed, Aug 24, 2011 at 03:14:30AM +0200, Frederic Weisbecker wrote:
> >  0001-cgroup-subsys-attach_task-should-be-called-after-mig.patch
> >  0002-cgroup-improve-old-cgroup-handling-in-cgroup_attach_.patch
> >  0003-cgroup-introduce-cgroup_taskset-and-use-it-in-subsys.patch
> >  0004-cgroup-don-t-use-subsys-can_attach_task-or-attach_ta.patch
> >  0005-cgroup-cpuset-don-t-use-ss-pre_attach.patch
> >  0006-cgroup-kill-subsys-can_attach_task-pre_attach-and-at.patch
> 
> I don't understand the point on patches 3,4,5,6
> 
> Why pushing the task iterations down to the subsystems?

I'll try again.

It seems like methods were added to serve the immediate need of the
particular user at the time and that in turn led to addition of
callbacks which were both superflous and incomplete (the bullet points
in the original message list them).  This seems to have happened
because extra interface was added without trying to make the existing
interface complete.

The interface is complicated and cumbersome to use - are
[can_]attach() called first or [can_]attach_task()?  What about
cancelation?  What if a subsys wants to perform operations across
multiple tasks atomically?

In general, iteration-by-callback is painful to use.  Establishing
common context (be it synchronization domain or shared variables)
becomes very cumbersome and implementation becomes fragmented and
difficult to follow.  For example, imagine how it would be like to use
list if we had call_for_each_list_entry(func, list_head) instead of
the control-loop style iterators we have know.

So, using iterators enables making all relevant information to each
stage of attach so that only one callback is required for each step -
the way it should be.  In addition, it makes it far easier for
subsystems to implement more involved logic in their methods.

I tried to make cgroup_freezer behave better which requires better
synchronization against the freezer and, with the current interface,
it's extremely ugly and painful.  The new interface is complete, easy
to understand and use with far less subtleties.

Thanks.

-- 
tejun
