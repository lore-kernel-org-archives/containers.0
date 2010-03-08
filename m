From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 03/12][user-cr] Add app_restart_args->debug
Date: Mon, 8 Mar 2010 13:39:29 -0600
Message-ID: <20100308193929.GA20030@us.ibm.com>
References: <20100305223439.GA15300@us.ibm.com>
	<20100305223723.GC15939@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100305223723.GC15939-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> 
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Thu, 4 Mar 2010 17:46:31 -0800
> Subject: [PATCH 03/12][user-cr] Add app_restart_args->debug
> 
> Make 'debug' a field in struct app_restart_args so other callers of
> app_restart() can also control the debug output of app_restart().
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
>  restart.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/restart.c b/restart.c
> index 314390c..87fff1e 100644
> --- a/restart.c
> +++ b/restart.c
> @@ -387,6 +387,7 @@ struct app_restart_args {
>  	int infd;
>  	int klogfd;
>  	long warn;
> +	int debug;
>  	long fail;
>  	int keep_lsm;
>  };
> @@ -583,7 +584,7 @@ static void parse_args(struct app_restart_args *args, int argc, char *argv[])
>  			args->copy_status = 1;
>  			break;
>  		case 'd':
> -			global_debug = 1;
> +			global_debug = args->debug = 1;

You don't actually need to also set global_debug here, right?

>  			break;
>  		case 'F':
>  			args->freezer = optarg;
> @@ -818,6 +819,7 @@ int app_restart(struct app_restart_args *args)
>  	ctx.args = args;
> 
>  	global_send_sigint = args->send_sigint;
> +	global_debug = args->debug;
> 
>  	/* input file descriptor (default: stdin) */
>  	if (args->infd >= 0) {
> -- 
> 1.6.0.4
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
