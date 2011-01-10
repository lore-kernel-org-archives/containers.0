From: Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 6/7] user namespaces: convert all capable checks in
	kernel/sys.c
Date: Mon, 10 Jan 2011 22:59:37 +0100
Message-ID: <20110110215937.GB21351__32895.1989686631$1294696835$gmane$org@wavehammer.waldi.eu.org>
References: <20110110211135.GA22446@mail.hallyn.com>
	<20110110211406.GF22564@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110110211406.GF22564-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Jan 10, 2011 at 09:14:07PM +0000, Serge E. Hallyn wrote:
> -	if (pcred->uid  != cred->euid &&
> -	    pcred->euid != cred->euid && !capable(CAP_SYS_NICE)) {
> +	if (pcred->user->user_ns != cred->user->user_ns &&
> +	    pcred->uid  != cred->euid &&
> +	    pcred->euid != cred->euid &&
> +	    !ns_capable(pcred->user->user_ns, CAP_SYS_NICE)) {

I don't think this is correct. This would not error out if the both
userns are the same. Because the same patern (check uid if same userns,
otherwise only capability) shows up in several parts of the code, maybe
this should be factored out.

> @@ -496,7 +498,7 @@ SYSCALL_DEFINE2(setregid, gid_t, rgid, gid_t, egid)
>  	if (rgid != (gid_t) -1) {
>  		if (old->gid == rgid ||
>  		    old->egid == rgid ||
> -		    capable(CAP_SETGID))
> +		    ns_capable(current_user_ns(), CAP_SETGID))

Would it not possible to add another function (nsown_capable?) that
checks against the own userns?

Bastian

-- 
Change is the essential process of all existence.
		-- Spock, "Let That Be Your Last Battlefield", stardate 5730.2
