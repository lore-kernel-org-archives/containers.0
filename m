From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: Review: Can we move init_restart_ctx() up ?
Date: Fri, 2 Oct 2009 18:48:58 -0700
Message-ID: <20091003014858.GA20762@us.ibm.com>
References: <20091002051456.GA6684@us.ibm.com> <4AC645D2.7030409@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AC645D2.7030409-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org] wrote:
| 
| 
| Sukadev Bhattiprolu wrote:
| > 
| > Would it be easier/cleaner if we initialized the restart ctx soon after
| > allocating it ? Looks like we already have the information we need at that
| > point.
| > 
| > That way, do_restart() won't need the 'pid' parameter and we anyway use
| > the 'if(ctx)' check to test for the coordinator.
| 
| I put the {checkpoint,restart}-related work in {checkpoint,restart}.c,
| and leave sys.c "neutral".
| 
| I also like the symmetry between do_checkpoint() and do_restart() :p
| 
| > BTW, can we move the '->active_pid = -1' in init_restart_ctx() to
| > ckpt_ctx_alloc() itself ?
| 
| @active_pid is specific to restart, that's why I initialize it there.

Ok. Spreading out the initialization code over different functions is a bit
confusing.  Maybe we could call init_checkpoint_ctx() or init_restart_ctx()
from ckpt_ctx_alloc() (depending on the kflags parameter) - and keep the
symmetry/nuetrality, But not a big deal.

Thanks,

Sukadev
