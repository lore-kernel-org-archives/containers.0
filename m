From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [RFC][PATCH][cryo] Save/restore state of unnamed pipes
Date: Thu, 19 Jun 2008 18:54:10 -0700
Message-ID: <20080620015410.GA13775@us.ibm.com>
References: <20080617212950.GB11826@us.ibm.com>
	<20080617223039.GB26942@us.ibm.com>
	<1213745472.16057.37.camel@localhost.localdomain>
	<20080618003214.GA14699@us.ibm.com>
	<1213754646.16057.107.camel@localhost.localdomain>
	<20080619075953.GA4295@us.ibm.com>
	<1213919160.28482.279.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1213919160.28482.279.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Matt Helsley [matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| 
| Yes, I think that's sufficient:
| 
|         int pipefds[2];
| 
| 	...
| 
| 	restarted_read_fd = 11;
| 	restarted_write_fd = 12;
| 
| 	...
| 
|         pipe(pipefds);
| 
| 	/* 
| 	 * pipe() may have returned one (or both) of the restarted fds
| 	 * at the wrong end of the pipe. This could cause dup2() to
| 	 * accidentaly close the pipe. Avoid that with an extra dup().
| 	 */
|         if (pipefds[1] == restarted_read_fd) {
| 		dup2(pipefds[1], last_fd + 1);
| 		pipefds[1] = last_fd + 1;
| 	}
| 
| 	if (pipefds[0] != restarted_read_fd) {
| 		dup2(pipefds[0], restarted_read_fd);
| 		close(pipefds[0]);
| 	}
| 
| 	if (pipefds[0] != restarted_read_fd) {
| 	        dup2(pipefds[1], restarted_write_fd);
| 		close(pipefds[1]);
| 	}

Shouldn't the last if be

	if (pipefds[1] != restarted_wrte_fd) ?

(otherwise it would break if pipefds[0] = 11 and pipefds[1] = 200)

I came up with something similar, but with an extra close(). And
in my code, I had restarted_* names referring to pipefds[] making
it a bit confusing initially.

How about using actual_fds[] (instead of pipefds) and expected_fds[]
instead of (restart_*) ? 

Thanks,

Suka

| 
| I think this code does the minimal number of operations needed in the
| restarted application too -- it counts on the second dup2() closing one
| of the fds if pipefds[1] == restarted_read_fd.
| 
| Cheers,
| 	-Matt
