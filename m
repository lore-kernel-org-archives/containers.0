From: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/3][cr][v2]: Checkpoint/restart file leases
Date: Fri, 30 Jul 2010 14:37:51 -0700
Message-ID: <1280525871.2451.23.camel__31535.8139844195$1280526042$gmane$org@localhost.localdomain>
References: <1274836063-13271-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1274836063-13271-3-git-send-email-sukadev@linux.vnet.ibm.com>
	<4C170430.2030708@cs.columbia.edu> <20100730191607.GA16238@us.ibm.com>
	<4C532BC9.6050109@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4C532BC9.6050109-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: matthew-Ztpu424NOJ8@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2010-07-30 at 15:45 -0400, Oren Laadan wrote:
> 
> Sukadev Bhattiprolu wrote:
> > Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> > | 
> > | 
> > | >  		h->fl_type = lock->fl_type;
> > | > +		h->fl_type_prev = lock->fl_type_prev;
> > | >  		h->fl_flags = lock->fl_flags;
> > | > +		if (h->fl_type & F_INPROGRESS && 
> > | > +					(lock->fl_break_time > jiffies))
> > | > +			h->fl_rem_lease = (lock->fl_break_time - jiffies) / HZ;
> > | 
> > | Hmmm -- we have a ctx->ktime_begin marking the start of the checkpoint.
> > | It is used for relative-time calculations, for example, the expiry of
> > | restart-blocks and timeouts.  I suggest that we use it here too to be
> > | consistent.
> > 
> > Well, I started off using ktime_begin but discussed this with John Stultz
> > (CC'd here) who pointed out that mixing different domains of time is likely
> > to cause errors. ktime is an absolute time and fl_break_time uses jiffies -
> > a relative time. 
> > 
> > I think use of ktime_begin for restart_blocks is fine (since they use
> > ktime_t) but using ktime_t for file leases and converting between jiffies
> > and nanoseconds could be a problem, unless we convert fl_break_time to
> > seconds.
> > 
> > IOW, can we leave the above computation of ->fl_rem_lease for now ?
> 
> The data on restart_blocks keep relative time - it's the the time
> to expiry relative to ktime_begin (which is absolute).
> 
> ktime_begin merely gives a reference point in time against which
> all other time-related values should be saved. The advantage is
> that all time computation are relative to the same point in time
> at checkpoint/restart - the time when the ktime_begin is set. It's
> more consistent this way.

First, forgive me for not being very aware of the checkpoint/restart
code. 

So, ktime_begin is an absolute CLOCK_MONOTONIC time, relative to the
time the system booted (more or less). And it represents the checkpoint
time, correct?

Is there a similar checkpointed jiffies value?


> I don't see the problem with jiffies vs ktime - there are functions
> to convert between different units (see jiffies.h). Even if you are
> concerned about reducing the resolution because of a conversion -
> well, it isn't realistic to expect nano-sec resolution after restart...

You're right, there are functions to convert from relative jiffies to
relative nanoseconds, but there really aren't good functions to convert
from absolute jiffies to absolute CLOCK_MONOTONIC time.

One can make a rough approximation, but its not a very precise method
with a number of complications (ie: 32bit jiffies wraps every ~50 days,
the INITIAL_JIFFIES offset has to be remembered, and the larger issue of
the fact that CLOCK_MONOTONIC is NTP corrected, while jiffies may or may
not be). So I'd strongly advise against trying to directly convert abs
jiffies values to abs CLOCK_MONOTONIC time.

thanks
-john
