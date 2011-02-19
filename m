From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 6/9] user namespaces: convert all capable checks
	in	kernel/sys.c
Date: Sat, 19 Feb 2011 18:52:46 +0100
Message-ID: <4D60036E.6040401__35551.8924458467$1298138103$gmane$org@free.fr>
References: <20110217150224.GA26334@mail.hallyn.com>
	<20110217150342.GF26395@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110217150342.GF26395-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 02/17/2011 04:03 PM, Serge E. Hallyn wrote:
> This allows setuid/setgid in containers.  It also fixes some
> corner cases where kernel logic foregoes capability checks when
> uids are equivalent.  The latter will need to be done throughout
> the whole kernel.
>
> Changelog:
> 	Jan 11: Use nsown_capable() as suggested by Bastian Blank.
> 	Jan 11: Fix logic errors in uid checks pointed out by Bastian.
> 	Feb 15: allow prlimit to current (was regression in previous version)
>
> Signed-off-by: Serge E. Hallyn<serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Acked-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

>
> -	if (!ns_capable(current->nsproxy->uts_ns->user_ns, CAP_SYS_ADMIN))
> +	if (!ns_capable(current->nsproxy->uts_ns->user_ns, CAP_SYS_ADMIN)) {
> +		printk(KERN_NOTICE "%s: did not have CAP_SYS_ADMIN\n", __func__);
>   		return -EPERM;
> +	}
> +	printk(KERN_NOTICE "%s: did have CAP_SYS_ADMIN\n", __func__);

A couple of printk left here.
