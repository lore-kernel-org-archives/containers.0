From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH][usercr]: Ghost tasks must be detached
Date: Wed, 9 Feb 2011 22:17:30 -0800
Message-ID: <20110210061730.GA25432@us.ibm.com>
References: <20101211033548.GA12584@us.ibm.com>
	<4D2BB78A.9090701@cs.columbia.edu>
	<4D4D9D1B.3000209@cs.columbia.edu>
	<20110205214032.GA12944@us.ibm.com>
	<4D4DC90B.3010103@cs.columbia.edu>
	<20110209020942.GA5339@us.ibm.com>
	<4D520B78.9020300@cs.columbia.edu>
	<20110210024430.GA23167@us.ibm.com>
	<4D536154.8000900@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D536154.8000900-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| 
| To address this, initially I thought that we could make ghosts take
| the tasklist_lock (write) when they change their ->exit_signal. 
| 
| But that's not enough because the parent may already be blocked in
| wait (so it's too late). Therefore, we also need to have ghosts 
| wake-up their parent through __wake_up_parent().
| 
| so something like:
| 
| void ghost_auto_reapable()
| {
| 	write_lock(&tasklist_lock);
| 	current->exit_signal = -1;
| 	__wake_up_sync_key(current, current->parent);
| 	write_unlock(&tasklist_lock);

You meant __wake_up_parent() here I guess.

But if we do this in do_ghost_task(), the parent could wakeup, find
that it still has a live child (this ghost) and go back to sleep before
the ghost becomes EXIT_DEAD right ?

If so, we would still have the problem ?

i.e we must stop being a chld a of the cinit for it to not wait for us.
Or we might need to detect that the the pidns is going away, so signalling
the parent won't cause any harm.  But that is racy too :-(

| }
| 
| If the parent wasn't at all waiting for us, no harm done...
| 
| > 
| > So you may ask how did the container-init have a ghost child. That was
| > due to a bug in usercr :-). 
| 
| You don't need a bug: the ghost flag is used for both ghost and dead
| tasks (the former used to instantiate specific pids, the latter to
| make other tasks orphans). So restarting a container that had orphan
| tasks is guaranteed to do this.

Ah, thats a good point.
