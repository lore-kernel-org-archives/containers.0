From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 16/16][cr][v3]: Restore file-leases
Date: Wed, 04 Aug 2010 19:35:44 -0400
Message-ID: <4C59F950.9080604__30860.5579579764$1280965060$gmane$org@cs.columbia.edu>
References: <1280877097-12377-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1280877097-12377-17-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1280877097-12377-17-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


How about adding the intro of this patch as a section in the
respective Documentation/checkpoint/.... ?

Oren.


On 08/03/2010 07:11 PM, Sukadev Bhattiprolu wrote:
> Restart an application with file-leases, from its checkpoint.
>
> Restart of file-lease that is not being broken (i.e F_INPROGRESS is not set)
> is almost identical to C/R of file-locks. i.e save the type of lease for the
> file in the checkpoint image and when restarting, restore the lease by calling
> do_setlease().
>
> C/R of file-lease gets complicated (I think), if a process is checkpointed
> when its lease was being revoked. i.e if P1 has a F_WRLCK lease on file F1
> and P2 opens F1 for write, P2's open is blocked for lease_break_time (45 secs).
> P1's lease is revoked (i.e set to F_UNLCK) and P1 is notified via a SIGIO to
> flush any dirty data.
>
> Basic design:
>
> To restore a lease that is being broken, we temporarily re-assign the original
> lease type (that we saved in ->fl_type_prev) to the lease-holder. i.e. in the
> above example, give P1 a F_WRLCK lease). When the lease-breaker (P2) is
> restarted after checkpoint, its open() system fails with -ERESTARTSYS and it
> will retry the open(). This open() will re-initiate the lease-break protocol
> (i.e P2 will go back to waiting and P1 will be notified).
>
> Some observations about this approach:
>
> 1. We must use ->fl_type_prev because, when the lease is being broken,
>    ->fl_type is already set to F_UNLCK and would not result in a
>    lease-break protocol when P2 is restarted.
>
> 2. When the lease-break is initiated and we signal the lease-holder, we set
>     the ->fl_break_notified field. When restarting the lease and repeating
>     the lease-break protocol, we check the ->fl_break_notified field and
>     signal the lease-holder only if did not signal before the checkpoint.
>
> 3. If P1 was was checkpointed 40 seconds into the lease_break_time,(i.e.
>     it had 5 seconds remaining in the lease), we would ideally want to ensure
>     that after restart, P1 gets 5 or at least 5 seconds to finish cleaning up
>     the lease.
>
>     But the actual time that P1 gets after the application is restarted
>     depends on many factors (number of processes in the application
>     process tree, load on system at the time of restart etc).
>
>     Jamie Lokier had suggested that we favor the lease-holder (P1) during
>     restart, even if it meant giving the lease-holder the entire lease-break
>     interval (45 seconds) again after the restart. Oren Laadan suggested
>     that rather than make that a kernel policy, we let the user choose a
>     policy based on the application's behavior.
>
>     The current patchset computes and checkpoints the remaining-lease and
>     uses this value to restore the lease. i.e the kernel simply uses the
>     "remaining-lease" value stored in the checkpoint image. Userspace tools
>     can be developed to alter the remaining-lease value in the checkpoint
>     image to either favor the lease-holder or the lease-breaker or to add
>     a fixed delta.
>
> 4. The above design of C/R of file-leases assumes that both lease-holder
>     and lease-breaker are restarted. If only the lease-holder is
>     restarted, the kernel will re-assign the original lease (F_WRLCK in
>     the example) to lease-holder. If no lease-breaker comes along, the
>     kernel will leave the lease assigned to lease-holder.
>
>     This should not be a problem because, as far as the lease-holder is
>     concerned the lease was revoked and it will/should reacquire the
>     lease.
>
> Changelog[v3]:
>
> 	- Broke-up patchset into smaller patches and addressed comments
> 	  from Oren Laadan, Jamie Lokier.
>
> Changelog[v2]:
> 	- comments from Matt Helsley, Serge Hallyn...

[...]
