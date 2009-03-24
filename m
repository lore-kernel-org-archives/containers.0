From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add UTS support (v4)
Date: Tue, 24 Mar 2009 08:21:27 -0700
Message-ID: <87d4c7gd54.fsf@caffeine.danplanet.com>
References: <1237402291-28812-1-git-send-email-danms@us.ibm.com>
	<49C8F74A.5000309@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

I'm a little confused.  Haven't you already reviewed v4?  Perhaps you
meant to reply to v5?

OL> Need to test whether cr_hbuf_get() succeeds (while now it's
OL> trivial, in the future it may fail if we change the allocation
OL> method).

Hmm, that's rather unfortunate as it seems to make it messier.  I've
long wondered, why not have cr_write_obj() do the allocation (and
check) so that we can avoid the get and put in the caller?  I suppose
that introduces an additional copy, but it seems like it would make it
significantly more attractive.

OL> The 'h.parent' fields is gone.

Okay.  I need to re-base on your latest.  Sorry about that.

OL> If we plan to support multiple uts_ns, then it makes sense to save
OL> the 'objref' value. If you omit the 'objref' because you assume a
OL> single namespace for all for now, then you may also drop the loop
OL> on all tasks (below), for now.

<snip>

OL> I'm still unhappy with this loop. It isn't necessary now, since we
OL> assume and enforce a single, common namespace among all tasks. It
OL> is unlikely to be useful as is in the future because the format is
OL> likely to change anyway.  Even in the (userspace) restart part the
OL> code to read it is in the global section as opposed to per task
OL> section. Is there any reason to keep it ?

I guess I'm not sure why the format would change.  Rather, I would
expect it to look something quite like this when we do support nested
namespaces.  By having it there, it keeps mktree organized in a
similar way for when we do support it.

However, if you'd rather be very explicit about the unsupported-ness
of it, then I can just completely re-write it to reflect the naive
case.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
