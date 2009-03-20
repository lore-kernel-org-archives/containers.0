From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Add powerpc signalfd syscall numbers
Date: Thu, 19 Mar 2009 23:09:03 -0700
Message-ID: <20090320060903.GA4360@us.ibm.com>
References: <20090320054420.GB26719@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090320054420.GB26719-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Argh, forgot to mention it's a patch for liblxc and not a kernel patch!

Also I'm taking lxc-devel-TtF/mJH4Jtrk1uMJSBkQmQ@public.gmane.org off Cc since it seems to refuse email
from non-members.

On Thu, Mar 19, 2009 at 10:44:20PM -0700, Matt Helsley wrote:
> Add signalfd and signalfd4 syscall number definitions for powerpc so
> that we may compile even with older platform headers.
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> diff --git a/src/lxc/start.c b/src/lxc/start.c
> index 476d695..051e70c 100644
> --- a/src/lxc/start.c
> +++ b/src/lxc/start.c
> @@ -51,6 +51,8 @@
>  #      define __NR_signalfd4 327
>  #    elif __x86_64__
>  #      define __NR_signalfd4 289
> +#    elif __powerpc__
> +#      define __NR_signalfd4 313
>  #    elif __s390x__
>  #      define __NR_signalfd4 322
>  #    endif
> @@ -62,6 +64,8 @@
>  #      define __NR_signalfd 321
>  #    elif __x86_64__
>  #      define __NR_signalfd 282
> +#    elif __powerpc__
> +#      define __NR_signalfd 305
>  #    elif __s390x__
>  #      define __NR_signalfd 316
>  #    endif

As best I can tell the only other syscall nr definitions missing for
powerpc are the checkpoint/restart ones. I figured those were probably
left out intentionally so I did not add them.

Cheers,
	-Matt Helsley
