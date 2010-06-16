From: Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>
Subject: Re: [RFC][PATCH 3/3][cr][v2]: fileleases: C/R of an in-progress lease.
Date: Wed, 16 Jun 2010 12:18:43 +0100
Message-ID: <20100616111843.GA15054__28458.5873866037$1276687207$gmane$org@shareable.org>
References: <1274836063-13271-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1274836063-13271-4-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1274836063-13271-4-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: matthew-Ztpu424NOJ8@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu wrote:
> If process P1 has a F_WRLCK lease on file F1 and process P2 opens the
> file, P2's open() blocks for lease_break_time (45 seconds) and P1 gets
> a SIGIO to cleanup it lease in preparation for P2's open.  If the two
> processes are checkpointed/restarted in this window, we should address
> following two issues:
> 
> 	- P1 should get a SIGIO only once for the lease (i.e if P1 got the
> 	  SIGIO before checkpoint, it should not get the SIGIO after restart).
> 
> 	- If R seconds remain in the lease, P2's open should be blocked for
> 	  at least the R seconds, so P1 has the time to clean up its lease.
> 	  The previous patch gives P1 the entire lease_break_time but that
> 	  can leave P2 stalled for 2*lease_break_time.
> 
> To address first, we add a field ->fl_break_notified to "remember" if we
> notified the lease-holder already. We save this field in the checkpoint
> image and when restarting, we notify the lease-holder only if this field
> is not set.
> 
> To address the second issue, we also checkpoint the ->fl_break_time for
> an in-progress lease. When restarting the process, we ensure that the
> lease-holder sleeps only for the remaining-lease rather than the entire
> lease.
> 
> These two fixes sound like an approximation (see comments in do_setlease()
> and __break_lease() below) and are also a bit kludgy (hence a separate patch
> for now).
> 
> Appreciate comments on how we can do this better. Specifically:
> 
> 	- do we even need to try and address the second issue above or
> 	  just let P1 have the entire lease_break_time again ?
> 
> 	- theoretically, the R seconds should start counting after *all*
> 	  processes in the application-process tree have been restarted,
> 	  since P1 waits inside the kernel for a portion of the remaining
> 	  lease - should we then add a delta to R ?

For P1 running out of time would be an abnormal error condition which
it might not be prepared to handle gracefully, and it's best if c/r
doesn't add new ones of those, perhaps due to the process tree restart
taking up too much of the time, perhaps exarcerbated by the processes
themselves if they take a burst of CPU reacting to the restart.

Also, P1 userspace may use an algorithm which is dependent on
lease_break_time, so it can do "check for lease break events -> no
events", and subsequently "check the time" is sufficient to confirm
that a particular file has not been opened and its contents can be
assumed unchanged.  Checking the time is faster.

P2 is unlikely to care about the timeout, as long as it doesn't get
permanently stuck.

So I would let P1 have the lease_break_time again, and/or set the
times ticking after the whole process tree is restarted and make sure
to round up any errors in favour of P1.

-- Jamie
