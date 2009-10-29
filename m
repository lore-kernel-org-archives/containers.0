From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 11/17] define function to print error messages to
	user log
Date: Wed, 28 Oct 2009 19:12:23 -0500
Message-ID: <20091029001223.GA1463@us.ibm.com>
References: <1256683587-23961-1-git-send-email-serge@us.ibm.com>
	<1256683587-23961-12-git-send-email-serge@us.ibm.com>
	<20091028181415.GB14023@count0.beaverton.ibm.com>
	<20091028205424.GA27394@us.ibm.com> <4AE8BCB5.4030406@librato.com>
	<20091028221208.GA30227@us.ibm.com> <4AE8C639.6090105@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AE8C639.6090105-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> >>
> >> Serge E. Hallyn wrote:
> >>> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> >>>>> @@ -401,6 +409,9 @@ char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
> >>>>>  		case 'E':
> >>>>>  			len += sprintf(format+len, "[%s]", "err %d");
> >>>>>  			break;
> >>>>> +		case 'C': /* count of bytes read/written to checkpoint image */
> >>>>> +			len += sprintf(format+len, "[%s]", "pos %d");
> >>>>> +			break;
> >>>> Instead we could always output ckpt->total and then we wouldn't need %(C). I
> >>>> suspect it's such a useful piece of information that it'll be repeated
> >>>> in many/all format strings eventually.
> >>> Yes, likewise %(T).  If that's what we want to do.
> >> I agree. For the cases when there is not task, can put "none"
> >>
> >>> Should we discuss here what we want an entry to look like?  For both
> >>> ckpt_write_err (to the checkpoint image) and ckpt_error()?
> >>>
> >> Yes please !
> > 
> > Actually %T isn't the current task, right, so it shouldn't always be prepended?
> > It actually is only meaningful during checkpoint_task(), collect_objs(), and
> > __tree_count_tasks?
> > 
> > Ok, so how about:
> > 
> > 	1. ckpt_write_err() always also calls ckpt_error() (which in turn calls
> > 		ckpt_debug).  Avoid duplication which exists in several places
> > 		right now.
> > 	2. We always prepend:
> > 
> > 		[current->pid]:[ctx->root_pid]:[ctx->active_pid]:[ctx->errno][ctx->total]
> > 
> > 	The %(X) expansions if specified come whereever they are in the fmt
> > 	string (which is what's happening now with my patchset).
> 
> So somewhere should set ctx->errno during a checkpoint.
> 
> I suppose active_pid is for restart, but it's redundant isn't it ?
> (it's always active_pid) - is it the different between top-level pid-ns
> and "current" pid-ns ?

No, I figured it would be meaningful for instance in places like
wait_task_active().

> Instead of writing root_pid repeatedly, why not write sometime at the
> beginning some "global" info about the checkpoint/restart ?  (e.g.
> the root_pid ...)

Well it is written out (for restart) at the end, so I suppose I should
switch restore_debug_free() to using ckpt_error() instead of ckpt_debug().

> > Kind of long, but again this is for ckpt_error and ckpt_write_err, not for all
> > ckpt_debugs().
> > 
> >>>>>  		case 'O':
> >>>>>  			len += sprintf(format+len, "[%s]", "obj %d");
> >>>>>  			break;
> >>>>> @@ -435,6 +446,51 @@ char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
> >>>>>  	return format;
> >>>>>  }
> >>>>>
> >>>>> +void ckpt_log_error(struct ckpt_ctx *ctx, char *fmt, ...)
> >>>>> +{
> >>>>> +	mm_segment_t fs;
> >>>>> +	struct file *file;
> >>>>> +	int count;
> >>>>> +	va_list ap, aq, az;
> >>>>> +	char *format;
> >>>>> +	char buf[200], *bufp = buf;
> >>>> I believe this buffer is too big for a kernel stack -- especially
> >>>> for ckpt_log_error() which might be invoked "deep" in
> >>>> the kernel stack.
> >>> 200 bytes?  Well, I guess I can try with 50 which still may often be
> >>> enough.
> >> How about using a dedicated buffer on @ctx for that ?
> > 
> > I was going to do that originally, but then thought back to your
> > comments about parallel checkpoint, and didn't feel like also adding
> > a spinlock.
> 
> We _will_ have some sort of locking when doing a parallel checkpoint.

Ok, so I'll set aside a big buffer and I'll just do a spinlock for now.

> So when we get there either use that lock, or (what I believe is more
> likely) create a per-checkpointer sub-data structure (a-la per-cpu).
> 
> Oren.
