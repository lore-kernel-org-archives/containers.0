From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 3/3][cr][v2]: fileleases: C/R of an in-progress lease.
Date: Wed, 16 Jun 2010 12:57:46 -0700
Message-ID: <20100616195746.GA29256__21445.0201056481$1276717704$gmane$org@us.ibm.com>
References: <1274836063-13271-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1274836063-13271-4-git-send-email-sukadev@linux.vnet.ibm.com>
	<4C18E534.80700@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4C18E534.80700-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, matthew-Ztpu424NOJ8@public.gmane.org
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| 
| 
| On 05/25/2010 09:07 PM, Sukadev Bhattiprolu wrote:
| > If process P1 has a F_WRLCK lease on file F1 and process P2 opens the
| > file, P2's open() blocks for lease_break_time (45 seconds) and P1 gets
| > a SIGIO to cleanup it lease in preparation for P2's open.  If the two
| > processes are checkpointed/restarted in this window, we should address
| > following two issues:
| > 
| > 	- P1 should get a SIGIO only once for the lease (i.e if P1 got the
| > 	  SIGIO before checkpoint, it should not get the SIGIO after restart).
| 
| The qualification "before" is vague in our case - a checkpoint is
| potentially a length operation, so before *which part* of the
| checkpoint you mean here ?

I should have been more specific. I meant - if P1 got the SIGIO before
freezing the container for checkpoint, it should not get the SIGIO after
restart/unfreeze. So checkpoint can take minutes, but if P2 is in the
same container and P2 is frozen too.

| > 
| > 	- If R seconds remain in the lease, P2's open should be blocked for
| > 	  at least the R seconds, so P1 has the time to clean up its lease.
| > 	  The previous patch gives P1 the entire lease_break_time but that
| > 	  can leave P2 stalled for 2*lease_break_time.
| > 
| > To address first, we add a field ->fl_break_notified to "remember" if we
| > notified the lease-holder already. We save this field in the checkpoint
| > image and when restarting, we notify the lease-holder only if this field
| > is not set.
| 
| I'm not sure I understand.
| 
| Signals are saved last, in particular they are saved after files, and
| file leases. What happens if we at checkpoint, we look at a file lease -
| we save the least_break_time, now we proceed with the checkpoint, now
| the lease expires before we are done, so we get a signal, and finally
| we save the signals. In this case, we get both an expiry time and the
| signal recorded.
| 
| (Am I mis-reading the code ?)

The signal is sent when P2 opens the file and lease-break is initiated.
No signal is sent when the lease actually expires.

So when P1 and P2 are *both frozen*, then only one of these are true right ?

	- P2 initiated the lease-break and sent the SIGIO or
	- the lease-break was not initiated at all

As youmentioned in your other email, I will look into the ctx->ktime_begin.
| 
| It seems to me that we need to mark the file lease at checkpoint to
| prevent the signal from being sent until _after_ the checkpoint ends
| (as opposed to remembering that the signal was sent). And then at the
| end of the checkpoint, iterate through the leases for each marked
| lease - remove the mark and fire the signal.
| 
| Oren.
