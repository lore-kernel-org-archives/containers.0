From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] cr_tests/ptree1: remove gratuitous sleeps
Date: Fri, 26 Feb 2010 12:54:10 -0800
Message-ID: <20100226205410.GD20106@count0.beaverton.ibm.com>
References: <1267213914-32219-1-git-send-email-ntl@pobox.com>
	<1267213914-32219-4-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1267213914-32219-4-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Feb 26, 2010 at 01:51:54PM -0600, Nathan Lynch wrote:
> These 1-second sleeps don't accomplish anything.

Acked-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> ---
>  process-tree/run-ptree1.sh |    4 ----
>  1 files changed, 0 insertions(+), 4 deletions(-)
> 
> diff --git a/process-tree/run-ptree1.sh b/process-tree/run-ptree1.sh
> index ed7ce9e..592d2d8 100755
> --- a/process-tree/run-ptree1.sh
> +++ b/process-tree/run-ptree1.sh
> @@ -87,8 +87,6 @@ function restart_container
>  	cmdline="$RESTART --pids --pidns --wait"
>  	$ECHO "\t- $cmdline"
> 
> -	sleep 1
> -
>  	$cmdline < $CHECKPOINT_FILE >> $SCRIPT_LOG 2>&1 &
>  }
> 
> @@ -178,8 +176,6 @@ while [ $cnt -lt 15 ]; do
> 
>  	create_fs_snapshot
> 
> -	sleep 1;
> -
>  	checkpoint $pid
> 
>  	touch $CHECKPOINT_DONE
> -- 
> 1.6.0.6
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
