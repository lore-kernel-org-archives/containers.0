From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH user-cr] return, don't exist, at coord error
Date: Sun, 18 Oct 2009 22:57:23 -0400
Message-ID: <4ADBD593.9070006@librato.com>
References: <20091019022942.GA21306@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091019022942.GA21306-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


What was the command line you used for the restart ?

Oren.

Serge E. Hallyn wrote:
> All right I can't explain it at the moment, but exit(1) at
> ckpt_coordinator() (on error) causes restart.c to exit with 0,
> whereas return(ret) causes it to correctly exit with -1.
> 
> Without this, a restart whose kernel portion ends with say
> -1 ends up returning from user-cr/restart.c with 0, so userspace
> can't tell whether sys_restart succeeded or failed.  With the
> patch, it fails correctly.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  restart.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/restart.c b/restart.c
> index e6e72ac..87899ba 100644
> --- a/restart.c
> +++ b/restart.c
> @@ -933,7 +933,7 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
>  		perror("restart failed");
>  		ckpt_verbose("Failed\n");
>  		ckpt_dbg("restart failed ?\n");
> -		exit(1);
> +		return ret;
>  	}
>  
>  	ckpt_verbose("Success\n");
