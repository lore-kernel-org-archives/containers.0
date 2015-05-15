From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2 2/2] coredump: add __printf attribute to cn_*printf
	functions
Date: Fri, 15 May 2015 09:54:04 -0500
Message-ID: <877fs9yjqr.fsf__36407.3645127521$1431701951$gmane$org@x220.int.ebiederm.org>
References: <554A0684.2000400@m4x.org>
	<1431656975-3563-1-git-send-email-nicolas.iooss_linux@m4x.org>
	<1431656975-3563-2-git-send-email-nicolas.iooss_linux@m4x.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1431656975-3563-2-git-send-email-nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org>
	(Nicolas Iooss's message of "Fri, 15 May 2015 10:29:35 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nicolas Iooss <nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Nicolas Iooss <nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org> writes:

> This allows detecting improper format string at build time, like:
>
>   fs/coredump.c:225:5: warning: format '%ld' expects argument of type
>   'long int', but argument 3 has type 'int' [-Wformat=]
>        err = cn_printf(cn, "%ld", cprm->siginfo->si_signo);
>        ^
>
> As si_signo is always an int, the format should be %d here.

Acked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>
> Signed-off-by: Nicolas Iooss <nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org>
> ---
>  fs/coredump.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
>
> diff --git a/fs/coredump.c b/fs/coredump.c
> index 833a57bc856c..e52e0064feac 100644
> --- a/fs/coredump.c
> +++ b/fs/coredump.c
> @@ -70,7 +70,8 @@ static int expand_corename(struct core_name *cn, int size)
>  	return 0;
>  }
>  
> -static int cn_vprintf(struct core_name *cn, const char *fmt, va_list arg)
> +static __printf(2, 0) int cn_vprintf(struct core_name *cn, const char *fmt,
> +				     va_list arg)
>  {
>  	int free, need;
>  	va_list arg_copy;
> @@ -93,7 +94,7 @@ again:
>  	return -ENOMEM;
>  }
>  
> -static int cn_printf(struct core_name *cn, const char *fmt, ...)
> +static __printf(2, 3) int cn_printf(struct core_name *cn, const char *fmt, ...)
>  {
>  	va_list arg;
>  	int ret;
> @@ -105,7 +106,8 @@ static int cn_printf(struct core_name *cn, const char *fmt, ...)
>  	return ret;
>  }
>  
> -static int cn_esc_printf(struct core_name *cn, const char *fmt, ...)
> +static __printf(2, 3)
> +int cn_esc_printf(struct core_name *cn, const char *fmt, ...)
>  {
>  	int cur = cn->used;
>  	va_list arg;
> @@ -225,7 +227,8 @@ static int format_corename(struct core_name *cn, struct coredump_params *cprm)
>  				break;
>  			/* signal that caused the coredump */
>  			case 's':
> -				err = cn_printf(cn, "%ld", cprm->siginfo->si_signo);
> +				err = cn_printf(cn, "%d",
> +						cprm->siginfo->si_signo);
>  				break;
>  			/* UNIX time of coredump */
>  			case 't': {
