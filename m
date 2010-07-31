From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/3][cr][v2]: Checkpoint/restart file leases
Date: Fri, 30 Jul 2010 18:36:53 -0700
Message-ID: <20100731013653.GC2927__1572.39289624176$1280540390$gmane$org@count0.beaverton.ibm.com>
References: <1274836063-13271-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1274836063-13271-3-git-send-email-sukadev@linux.vnet.ibm.com>
	<4C170430.2030708@cs.columbia.edu>
	<20100730191607.GA16238@us.ibm.com>
	<4C532BC9.6050109@cs.columbia.edu>
	<1280525871.2451.23.camel@localhost.localdomain>
	<4C5352EF.9080601@cs.columbia.edu>
	<20100731003504.GA3544@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100731003504.GA3544-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: matthew-Ztpu424NOJ8@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jul 30, 2010 at 05:35:04PM -0700, Sukadev Bhattiprolu wrote:
> Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> >
> >
> > john stultz wrote:
> >> On Fri, 2010-07-30 at 15:45 -0400, Oren Laadan wrote:
> >>> Sukadev Bhattiprolu wrote:
> >>>> Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> >>>> | | | >  		h->fl_type = lock->fl_type;
> >>>> | > +		h->fl_type_prev = lock->fl_type_prev;
> >>>> | >  		h->fl_flags = lock->fl_flags;
> >>>> | > +		if (h->fl_type & F_INPROGRESS && | > 
> >>>> +					(lock->fl_break_time > jiffies))
> >>>> | > +			h->fl_rem_lease = (lock->fl_break_time - jiffies) / HZ;
> >>>> | | Hmmm -- we have a ctx->ktime_begin marking the start of the 
> >>>> checkpoint.
> >>>> | It is used for relative-time calculations, for example, the expiry of
> >>>> | restart-blocks and timeouts.  I suggest that we use it here too to be
> >>>> | consistent.
> >>>>
> >>>> Well, I started off using ktime_begin but discussed this with John Stultz
> >>>> (CC'd here) who pointed out that mixing different domains of time is likely
> >>>> to cause errors. ktime is an absolute time and fl_break_time uses jiffies -
> >>>> a relative time. 
> >>>>
> >>>> I think use of ktime_begin for restart_blocks is fine (since they use
> >>>> ktime_t) but using ktime_t for file leases and converting between jiffies
> >>>> and nanoseconds could be a problem, unless we convert fl_break_time to
> >>>> seconds.
> >>>>
> >>>> IOW, can we leave the above computation of ->fl_rem_lease for now ?
> >>> The data on restart_blocks keep relative time - it's the the time
> >>> to expiry relative to ktime_begin (which is absolute).
> >>>
> >>> ktime_begin merely gives a reference point in time against which
> >>> all other time-related values should be saved. The advantage is
> >>> that all time computation are relative to the same point in time
> >>> at checkpoint/restart - the time when the ktime_begin is set. It's
> >>> more consistent this way.
> >>
> >> First, forgive me for not being very aware of the checkpoint/restart
> >> code. 
> >
> > On the contrary, forgive me if I'm stating the obvious below ...
> >
> >>
> >> So, ktime_begin is an absolute CLOCK_MONOTONIC time, relative to the
> >> time the system booted (more or less). And it represents the checkpoint
> >> time, correct?
> >
> > As a rule, all time measurements in the checkpoint image are
> > saved as relative values, using the start-of-checkpoint as the
> > reference point in time (*).
> >
> > So at checkpoint, every absolute time value should be converted
> > to a value relative to the start-of-checkpoint. At restart, every
> > relative time value from the image is converted back (if needed)
> > to an absolute time value using a respective start-of-restart.
> 
> One general observation, slightly off-topic. You mention 
> "start-of-restart" here and ...
> >
> > This makes sense for the most common case, where if a process
> > had 5 more seconds to sleep at the time of checkpoint, we would
> > like it to have 5 more seconds to sleep after it restarts.
> 
> ... "after it restarts" here. These two can be quite different if,
> as you mention below, the C/R is a lengthy operation.

Worse! I think the big concern is not the duration of checkpoint but the
amount of time userspace expects to store a checkpoint before
restarting.

It's an arbitrary amount of time. A user could restart 50 days later.
Or 100. etc. Sure, it's _unlikely_, but we (checkpoint/restart implementers)
shouldn't count on seeing only "reasonable" times between completion of
checkpoint and initiation of restart. We need to be robust for all
the times we see.

I think that's why Oren made the choices he did. Making times relative
to ktime_begin certainly helps keep the time values semi-sane for those
crazy arbitrary cases in addition to being nice for the "reasonable"
cases.

Cheers,
	-Matt
