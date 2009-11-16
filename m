From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 6/7] have ckpt_err set ctx->errno
Date: Mon, 16 Nov 2009 11:24:20 -0500
Message-ID: <4B017CB4.10707@cs.columbia.edu>
References: <1257465619-1777-1-git-send-email-serue@us.ibm.com>
	<1257465619-1777-7-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257465619-1777-7-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Move setting of ctx->errno into do_ckpt_msg().  We leave a small separate
> function to notify all restarting tasks in case of failure.  We use a
> CKPT_CTX_WOKEN bit for this.  If we always notify restarting tasks of
> failure inside do_ckpt_msg() then we will have to be more careful about
> when ckpt_err() is called at restart.  Only 4 instances were doing the

I don't think it is wrong to notify of errors and wakeup tasks
"too early" or multiple times. In fact, the first one to notify
an error (test-and-set of ctx->errno) should do that. What am I
missing ?

> wakeup right now (at the end of each possible restart sequence), and we
> don't want to risk moving notification too early.
> 
> This patch also fixes what should have been a problem before: always
> init_completion(&complete), else we might complete(&complete) on random junk

Nice catch.

[...]

Oren.
