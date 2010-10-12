From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/2] Kconfig : remove pid_ns and net_ns experimental
Date: Tue, 12 Oct 2010 13:53:55 -0400
Message-ID: <4CB4A0B3.10401@cs.columbia.edu>
References: <1286457333-10500-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1286457333-10500-1-git-send-email-daniel.lezcano-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel,

Maybe you can throw this on in the series as well ?
http://www.mail-archive.com/linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg01431.html

It's a one-liner to move the namespaces options into its own
sub-menu under 'General Setup'.

Oren.


On 10/07/2010 09:15 AM, Daniel Lezcano wrote:
> The pid namespace is in the kernel since 2.6.27 and the net_ns
> since 2.6.29. They are enabled in the distro by default and used by
> userspace component. They are mature enough to remove the 'experimental'
> label.
>
> Signed-off-by: Daniel Lezcano<daniel.lezcano-GANU6spQydw@public.gmane.org>
> ---
>   init/Kconfig |    9 +++------
>   1 files changed, 3 insertions(+), 6 deletions(-)
>
> diff --git a/init/Kconfig b/init/Kconfig
> index a175935..a52124e 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -759,21 +759,18 @@ config USER_NS
>   	  If unsure, say N.
>
>   config PID_NS
> -	bool "PID Namespaces (EXPERIMENTAL)"
> +	bool "PID Namespaces"
>   	default n
> -	depends on NAMESPACES&&  EXPERIMENTAL
> +	depends on NAMESPACES
>   	help
>   	  Support process id namespaces.  This allows having multiple
>   	  processes with the same pid as long as they are in different
>   	  pid namespaces.  This is a building block of containers.
>
> -	  Unless you want to work with an experimental feature
> -	  say N here.
> -
>   config NET_NS
>   	bool "Network namespace"
>   	default n
> -	depends on NAMESPACES&&  EXPERIMENTAL&&  NET
> +	depends on NAMESPACES&&  NET
>   	help
>   	  Allow user space to create what appear to be multiple instances
>   	  of the network stack.
