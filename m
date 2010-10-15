From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Kconfig : default all the namespaces to 'yes'
Date: Thu, 14 Oct 2010 22:05:00 -0500
Message-ID: <20101015030500.GA28473@hallyn.com>
References: <1286457333-10500-1-git-send-email-daniel.lezcano@free.fr>
	<1286457333-10500-2-git-send-email-daniel.lezcano@free.fr>
	<20101011185757.GJ23839@count0.beaverton.ibm.com>
	<20101012171622.GA16543@hallyn.com> <4CB53F1C.7020709@free.fr>
	<20101013144430.GA20904@hallyn.com>
	<20101014165106.1ab36714.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20101014165106.1ab36714.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Biederman Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Andrew Morton (akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org):
> On Wed, 13 Oct 2010 09:44:30 -0500
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> > > On 10/12/2010 07:16 PM, Serge E. Hallyn wrote:
> > > >Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > > >>On Thu, Oct 07, 2010 at 03:15:33PM +0200, Daniel Lezcano wrote:
> > > >>>As the different namespaces depend on 'CONFIG_NAMESPACES', it is
> > > >>>logical to enable all the namespaces when we enable NAMESPACES.
> > > >>>
> > > >>>Signed-off-by: Daniel Lezcano<daniel.lezcano-GANU6spQydw@public.gmane.org>
> > > >>Subject of the patch email is a little confusing as it's not
> > > >>quite what happens. I'm mostly OK with it but I'm not sure we
> > > >>should enable user-ns by default just yet.
> > > >>
> > > >>Acked-By: Matt Helsley<matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > > >In fact, perhaps we should keep the experimental tag on user namespaces.
> > > 
> > > The experimental tag is kept on the user namespace. This one is
> > > defaulting to yes when the namespaces and experimental are selected.
> > 
> > Oh, sounds good
> > 
> 
> My attention flagged.  Can we please confirm that the current patch is
> still good?

Yup, the patch below only sets USER_NS=y when EXPERIMENTAL=y, which I'd
failed to notice the first time.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

> From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
> 
> As the different namespaces depend on 'CONFIG_NAMESPACES', it is logical
> to enable all the namespaces when we enable NAMESPACES.
> 
> Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
> Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Acked-By: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> ---
> 
>  init/Kconfig |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff -puN init/Kconfig~namespaces-default-all-the-namespaces-to-yes-when-config_namespaces-is-selected init/Kconfig
> --- a/init/Kconfig~namespaces-default-all-the-namespaces-to-yes-when-config_namespaces-is-selected
> +++ a/init/Kconfig
> @@ -739,6 +739,7 @@ config NAMESPACES
>  config UTS_NS
>  	bool "UTS namespace"
>  	depends on NAMESPACES
> +	default y
>  	help
>  	  In this namespace tasks see different info provided with the
>  	  uname() system call
> @@ -746,6 +747,7 @@ config UTS_NS
>  config IPC_NS
>  	bool "IPC namespace"
>  	depends on NAMESPACES && (SYSVIPC || POSIX_MQUEUE)
> +	default y
>  	help
>  	  In this namespace tasks work with IPC ids which correspond to
>  	  different IPC objects in different namespaces.
> @@ -753,6 +755,7 @@ config IPC_NS
>  config USER_NS
>  	bool "User namespace (EXPERIMENTAL)"
>  	depends on NAMESPACES && EXPERIMENTAL
> +	default y
>  	help
>  	  This allows containers, i.e. vservers, to use user namespaces
>  	  to provide different user info for different servers.
> @@ -760,8 +763,8 @@ config USER_NS
>  
>  config PID_NS
>  	bool "PID Namespaces"
> -	default n
>  	depends on NAMESPACES
> +	default y
>  	help
>  	  Support process id namespaces.  This allows having multiple
>  	  processes with the same pid as long as they are in different
> @@ -769,8 +772,8 @@ config PID_NS
>  
>  config NET_NS
>  	bool "Network namespace"
> -	default n
>  	depends on NAMESPACES && NET
> +	default y
>  	help
>  	  Allow user space to create what appear to be multiple instances
>  	  of the network stack.
> _
