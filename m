From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH v3 05/11] syslog_ns: make permisiion check per user
	namespace
Date: Wed, 7 Aug 2013 20:41:25 +0200
Message-ID: <1375900885.2644.76.camel__2329.19599297947$1375900921$gmane$org@deadeye.wl.decadent.org.uk>
References: <1375861035-24320-1-git-send-email-rui.xiang@huawei.com>
	<1375861035-24320-6-git-send-email-rui.xiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375861035-24320-6-git-send-email-rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rui Xiang <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, libo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, guz.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2013-08-07 at 15:37 +0800, Rui Xiang wrote:
> Use ns_capable to check capability in user ns,
> instead of capable function. The user ns is the
> owner of current syslog ns.
> 
> Signed-off-by: Rui Xiang <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
>  kernel/printk.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/printk.c b/kernel/printk.c
> index e508ab2..ca951e7 100644
> --- a/kernel/printk.c
> +++ b/kernel/printk.c
> @@ -374,13 +374,13 @@ static int check_syslog_permissions(int type, bool from_file,
>  		return 0;
>  
>  	if (syslog_action_restricted(type, ns)) {
> -		if (capable(CAP_SYSLOG))
> +		if (ns_capable(ns->owner, CAP_SYSLOG))
>  			return 0;
>  		/*
>  		 * For historical reasons, accept CAP_SYS_ADMIN too, with
>  		 * a warning.
>  		 */
> -		if (capable(CAP_SYS_ADMIN)) {
> +		if (ns_capable(ns->owner, CAP_SYS_ADMIN)) {
>  			pr_warn_once("%s (%d): Attempt to access syslog with "
>  				     "CAP_SYS_ADMIN but no CAP_SYSLOG "
>  				     "(deprecated).\n",

Since CAP_SYS_ADMIN is only accepted for backward compatibility, is it
really necessary to accept it as a per-namespace capability too?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
