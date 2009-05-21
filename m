From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/4] Add -P <pid-file> option to ns_exec
Date: Thu, 21 May 2009 11:35:40 -0500
Message-ID: <20090521163540.GA18281@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> 
> ns_exec knows the pid of the container-init in its own namespace (this
> is usually the global pid since we normally run ns_exec in init-pid-ns).
> If ns_exec writes out this "global" pid to a file, wrapper scripts can
> find the process they created more easily.
> 
> killall and pidof assume that all previous instances of the test program
> have thawed and exited gracefully :-) As such they are not very friendly
> during early testing and/or complicate the wrapper scripts.
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
>  ns_exec.c |   28 ++++++++++++++++++++++++++--
>  1 files changed, 26 insertions(+), 2 deletions(-)
> 
> diff --git a/ns_exec.c b/ns_exec.c
> index 5d5cca3..d15daa0 100644
> --- a/ns_exec.c
> +++ b/ns_exec.c
> @@ -24,7 +24,7 @@ static const char* procname;
> 
>  static void usage(const char *name)
>  {
> -	printf("usage: %s [-h] [-c] [-muip]"
> +	printf("usage: %s [-h] [-c] [-muip] [-P <pid-file>]"
>  			"[command [arg ..]]\n", name);
>  	printf("\n");
>  	printf("  -h		this message\n");
> @@ -33,6 +33,7 @@ static void usage(const char *name)
>  	printf("  -m		mount namespace\n");
>  	printf("  -u		utsname namespace\n");
>  	printf("  -i		ipc namespace\n");
> +	printf("  -P <pid-file>	File in which to write global pid of cinit\n");

We probably don't care, but it's not necessarily the global pid.

Applying as is, bc I can't think of a better adjective.

thanks,
-serge
