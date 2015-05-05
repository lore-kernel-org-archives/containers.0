From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 1/2] coredump: use from_kuid/kgid_munged when formatting
	corename
Date: Tue, 05 May 2015 14:13:24 -0500
Message-ID: <87bnhyhm7f.fsf@x220.int.ebiederm.org>
References: <1429181404.2850.44.camel@perches.com>
	<1430649246-32726-1-git-send-email-nicolas.iooss_linux@m4x.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1430649246-32726-1-git-send-email-nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org>
	(Nicolas Iooss's message of "Sun, 3 May 2015 18:34:05 +0800")
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

> When adding __printf attribute to cn_printf, gcc reports some issues:
>
>   fs/coredump.c:213:5: warning: format '%d' expects argument of type
>   'int', but argument 3 has type 'kuid_t' [-Wformat=]
>        err = cn_printf(cn, "%d", cred->uid);
>        ^
>   fs/coredump.c:217:5: warning: format '%d' expects argument of type
>   'int', but argument 3 has type 'kgid_t' [-Wformat=]
>        err = cn_printf(cn, "%d", cred->gid);
>        ^
>
> These warnings come from the fact that the value of uid/gid needs to be
> extracted from the kuid_t/kgid_t structure before being used as an
> integer.  More precisely, cred->uid and cred->gid need to be converted
> to either user-namespace uid/gid or to init_user_ns uid/gid.
>
> As Documentation/sysctl/kernel.txt does not specify which user namespace
> is used to translate %u and %g in core_pattern, but lowercase %p and %i
> are used to format pid/tid in the current process namespace, it seems
> intuitive that lowercase %u and %g use the current user namespace.

I love the logic of lower vs upper case letters in the selection of how
an identifier should be used.  Unfortunately I can't support it.

Converting to anything other than init_user_ns will actually be an ABI
break.  Which in practice should trump everything else.

Further only the global root user can set this value, which largely
implies that the program setting the core dump patter will expect the
values to be in the initial user namespace.

In practice your patch allows any user to put any uid they want on core
files which seems to make the uid parameter useless.

So for all of the reasons above I think we need to print uids and gids
in the initial user namespace unless explicitly requested to do so.

> While at it, format uid and gid values with %u instead of %d because
> uid_t/__kernel_uid32_t and gid_t/__kernel_gid32_t are unsigned int.
>
> Signed-off-by: Nicolas Iooss <nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org>
> ---
>  fs/coredump.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/fs/coredump.c b/fs/coredump.c
> index bbbe139ab280..99c8af640c5a 100644
> --- a/fs/coredump.c
> +++ b/fs/coredump.c
> @@ -209,11 +209,15 @@ static int format_corename(struct core_name *cn, struct coredump_params *cprm)
>  				break;
>  			/* uid */
>  			case 'u':
> -				err = cn_printf(cn, "%d", cred->uid);
> +				err = cn_printf(cn, "%u",
> +						from_kuid_munged(cred->user_ns,
> +								 cred->uid));
>  				break;
>  			/* gid */
>  			case 'g':
> -				err = cn_printf(cn, "%d", cred->gid);
> +				err = cn_printf(cn, "%u",
> +						from_kgid_munged(cred->user_ns,
> +								 cred->gid));
>  				break;
>  			case 'd':
>  				err = cn_printf(cn, "%d",
