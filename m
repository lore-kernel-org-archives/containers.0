From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: ctx->pipe_child bug ?
Date: Sat, 22 Jan 2011 13:28:22 -0500
Message-ID: <4D3B21C6.70801@cs.columbia.edu>
References: <20110121073918.GA15385@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110121073918.GA15385-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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



On 01/21/2011 02:39 AM, Sukadev Bhattiprolu wrote:
> Oren,
> 
> 
> In usercr commit 0dd3f9dacc0a08f5fb562e385a4e4244f453b41c we have the following
> diff:
> 
> @@ -1868,10 +1902,16 @@ static int ckpt_fork_feeder(struct ckpt_ctx *ctx)
>         close(ctx->pipe_child[0]);
>         ctx->pipe_out = ctx->pipe_child[1];
> 
> +       ctx->pipe_child[0] = -1;  /* mark unused */
> +       ctx->pipe_child[1] = -1;  /* mark unused */
> 
> ---
> 
> ckpt_fork_feeder() creates the ->pipe_child[] pipe and clones the fork_feeder.
> ckpt_do_feeder() does the following:
> 
> 
>         /* children pipe */
>         close(ctx->pipe_child[1]);
>         ctx->pipe_in = ctx->pipe_child[0];
> 
>         /* feeder pipe */
>         close(ctx->pipe_feed[0]);
> 
> But if the fork_feeder process runs after the parent marks the fds unused, the
> fork feeder would end up with a -1 in ctx->pipe_in right ?
> 
> The two threads don't share the fds but they do share the same VM and hence
> changes to 'ctx' in one process is visible in the other right ?

Good catch. I'll fix that, thanks.

Oren.
