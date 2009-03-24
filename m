From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add UTS support (v4)
Date: Tue, 24 Mar 2009 11:34:54 -0400
Message-ID: <49C8FD9E.1020600@cs.columbia.edu>
References: <1237402291-28812-1-git-send-email-danms@us.ibm.com>	<49C8F74A.5000309@cs.columbia.edu>
	<87d4c7gd54.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d4c7gd54.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org



Dan Smith wrote:
> I'm a little confused.  Haven't you already reviewed v4?  Perhaps you
> meant to reply to v5?

Uhhhhh... you are so right and I'm so confused ..
Sorry, ignore those comments please.

> 
> OL> Need to test whether cr_hbuf_get() succeeds (while now it's
> OL> trivial, in the future it may fail if we change the allocation
> OL> method).
> 
> Hmm, that's rather unfortunate as it seems to make it messier.  I've
> long wondered, why not have cr_write_obj() do the allocation (and
> check) so that we can avoid the get and put in the caller?  I suppose
> that introduces an additional copy, but it seems like it would make it
> significantly more attractive.
> 
> OL> The 'h.parent' fields is gone.
> 
> Okay.  I need to re-base on your latest.  Sorry about that.
> 
> OL> If we plan to support multiple uts_ns, then it makes sense to save
> OL> the 'objref' value. If you omit the 'objref' because you assume a
> OL> single namespace for all for now, then you may also drop the loop
> OL> on all tasks (below), for now.
> 
> <snip>
> 
> OL> I'm still unhappy with this loop. It isn't necessary now, since we
> OL> assume and enforce a single, common namespace among all tasks. It
> OL> is unlikely to be useful as is in the future because the format is
> OL> likely to change anyway.  Even in the (userspace) restart part the
> OL> code to read it is in the global section as opposed to per task
> OL> section. Is there any reason to keep it ?
> 
> I guess I'm not sure why the format would change.  Rather, I would
> expect it to look something quite like this when we do support nested
> namespaces.  By having it there, it keeps mktree organized in a
> similar way for when we do support it.

I'd expect it to be a per task information, as opposed to a "global"
part, similar to a session ID. I don't see how the restart of ns can
be done by the first task (in the "global" part) only. While we have
not implemented anything yet, it sounds to me that the right place
to do that will be per task.

In other words, it makes sense to save that information for each task,
but, I think, not as a separate and dedicated array only handled in
the "global" part.

Hence my suggestion that you do dump that information, but instead of
that loop, you add it to the existing array of tasks that is written,
and extend the 'struct cr_hdr_pids'. It's flexible to be used "global"
or per-task.

> However, if you'd rather be very explicit about the unsupported-ness
> of it, then I can just completely re-write it to reflect the naive
> case.

We're already explicit in the test for 'nxproxy != ctx->task->nxproxy'...

Oren.
