From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH][usercr]: Ghost tasks must be detached
Date: Thu, 10 Feb 2011 09:42:18 -0800
Message-ID: <20110210174218.GA1025@us.ibm.com>
References: <4D2BB78A.9090701@cs.columbia.edu>
	<4D4D9D1B.3000209@cs.columbia.edu>
	<20110205214032.GA12944@us.ibm.com>
	<4D4DC90B.3010103@cs.columbia.edu>
	<20110209020942.GA5339@us.ibm.com>
	<4D520B78.9020300@cs.columbia.edu>
	<20110210024430.GA23167@us.ibm.com>
	<4D536154.8000900@cs.columbia.edu>
	<20110210061730.GA25432@us.ibm.com>
	<4D53FC9C.1050405@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D53FC9C.1050405-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
| 
| On 02/10/2011 01:17 AM, Sukadev Bhattiprolu wrote:
| > Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| > | 
| > | To address this, initially I thought that we could make ghosts take
| > | the tasklist_lock (write) when they change their ->exit_signal. 
| > | 
| > | But that's not enough because the parent may already be blocked in
| > | wait (so it's too late). Therefore, we also need to have ghosts 
| > | wake-up their parent through __wake_up_parent().
| > | 
| > | so something like:
| > | 
| > | void ghost_auto_reapable()
| > | {
| > | 	write_lock(&tasklist_lock);
| > | 	current->exit_signal = -1;
| > | 	__wake_up_sync_key(current, current->parent);
| > | 	write_unlock(&tasklist_lock);
| > 
| > You meant __wake_up_parent() here I guess.

Hmm, can we have the above wakeup and, like in 2.6.32, have do_wait_thread()
skip over detached tasks ? Since we set ->exit_signal above,
do_wait_thread() should not wait for us.

I will go through Oleg's patch earlier again. But my guess, without C/R
do_wait_thread() had no reason to have a detached child in do_wait_thread()
which is probably why Oleg removed it.

I will look at the exit_checkpoint() change you mention later today.

Sukadev
