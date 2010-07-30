From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 2/3][cr][v2]: Checkpoint/restart file leases
Date: Fri, 30 Jul 2010 12:16:07 -0700
Message-ID: <20100730191607.GA16238__40980.2055605271$1280518837$gmane$org@us.ibm.com>
References: <1274836063-13271-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1274836063-13271-3-git-send-email-sukadev@linux.vnet.ibm.com>
	<4C170430.2030708@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4C170430.2030708-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: matthew-Ztpu424NOJ8@public.gmane.org, johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| 
| 
| >  		h->fl_type = lock->fl_type;
| > +		h->fl_type_prev = lock->fl_type_prev;
| >  		h->fl_flags = lock->fl_flags;
| > +		if (h->fl_type & F_INPROGRESS && 
| > +					(lock->fl_break_time > jiffies))
| > +			h->fl_rem_lease = (lock->fl_break_time - jiffies) / HZ;
| 
| Hmmm -- we have a ctx->ktime_begin marking the start of the checkpoint.
| It is used for relative-time calculations, for example, the expiry of
| restart-blocks and timeouts.  I suggest that we use it here too to be
| consistent.

Well, I started off using ktime_begin but discussed this with John Stultz
(CC'd here) who pointed out that mixing different domains of time is likely
to cause errors. ktime is an absolute time and fl_break_time uses jiffies -
a relative time. 

I think use of ktime_begin for restart_blocks is fine (since they use
ktime_t) but using ktime_t for file leases and converting between jiffies
and nanoseconds could be a problem, unless we convert fl_break_time to
seconds.

IOW, can we leave the above computation of ->fl_rem_lease for now ?

Sukadev
