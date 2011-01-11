From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: global_send_sigint
Date: Mon, 10 Jan 2011 20:59:17 -0500
Message-ID: <4D2BB975.2010306@cs.columbia.edu>
References: <20100225034746.GA18829@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100225034746.GA18829-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


At the moment, at least @klogd field has to be set manually.

Perhaps it would be better to provide a pre-initialized struct,
so that users could do:

  args = CR_RESTART_ARGS;
or
  cr_init_restart_args(&args);

?

Oren


On 02/24/2010 10:47 PM, Sukadev Bhattiprolu wrote:
> 
> global_send_sigint is -1 by default. 
> 
> If it is -1, we either send SIGKILL or SIGINIT depending on whether
> we started "new pidns with init" or "new pidns without init".
> 
> If global_send_sigint is explicitly set to 0 by user (--signal is set).
> no signal is sent.
> 
> Given that we are making restart() available in libcheckpoint.a, would
> it make sense to switch the behaviors of 0 and -1 ?
> 
> i.e if global_send_sigint is 0, send the default signal (SIGINT or SIGKILL).
> If it is -1, then don't send any signal.
> 
> That way, applications of restart() (i.e LXC) can simply
> 
> 	memset(&args, 0, sizeof(args))
> 
> and get the default behavior. Now they have to explicitly set to -1.
> 
> Sukadev
> 
