From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH][cryo] Save/restore state of unnamed pipes
Date: Thu, 19 Jun 2008 19:48:19 -0700
Message-ID: <1213930099.28482.418.camel@localhost.localdomain>
References: <20080617212950.GB11826@us.ibm.com>
	<20080617223039.GB26942@us.ibm.com>
	<1213745472.16057.37.camel@localhost.localdomain>
	<20080618003214.GA14699@us.ibm.com>
	<1213754646.16057.107.camel@localhost.localdomain>
	<20080619075953.GA4295@us.ibm.com>
	<1213919160.28482.279.camel@localhost.localdomain>
	<20080620015410.GA13775@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080620015410.GA13775-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


On Thu, 2008-06-19 at 18:54 -0700, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> Matt Helsley [matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:

<snip>

> | 	if (pipefds[0] != restarted_read_fd) {
> | 	        dup2(pipefds[1], restarted_write_fd);
> | 		close(pipefds[1]);
> | 	}
> 
> Shouldn't the last if be
> 
> 	if (pipefds[1] != restarted_wrte_fd) ?
> 
> (otherwise it would break if pipefds[0] = 11 and pipefds[1] = 200)

Argh, copy-paste error. You are correct.

> I came up with something similar, but with an extra close(). And
> in my code, I had restarted_* names referring to pipefds[] making
> it a bit confusing initially.
> 
> How about using actual_fds[] (instead of pipefds) and expected_fds[]
> instead of (restart_*) ? 

I like actual_fds[] instead of pipefds[] but still prefer the restart_*
names over expected_fds[].

Cheers,
	-Matt
