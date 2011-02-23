From: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/9] security: Make capabilities relative to the user
	namespace.
Date: Wed, 23 Feb 2011 11:40:09 +0000
Message-ID: <29256.1298461209__15490.6333344572$1298462852$gmane$org@redhat.com>
References: <20110217150306.GB26395@mail.hallyn.com>
	<20110217150224.GA26334@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110217150306.GB26395-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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

Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:

>  	int (*capable) (struct task_struct *tsk, const struct cred *cred,
> -			int cap, int audit);
> +			struct user_namespace *ns, int cap, int audit);

Hmmm...  A chunk of the contents of the cred struct are user-namespaced.
Could you add the user_namespace pointer to the cred struct and thus avoid
passing it as an argument to other things.

In fact, I think you probably have to do this so that cachefiles, for example,
can override the user namespace when it operates on behalf of a process that's
in another namespace.

In fact, looking later on in your patch, I see:

> -		    || (cap_capable(current, current_cred(), CAP_SETPCAP,
> +		    || (cap_capable(current, current_cred(),
> +				    current_cred()->user->user_ns, CAP_SETPCAP,

so the user_ns _is_ already available through the creds.  So is there really a
need to pass it as an argument to anything that already takes a cred?

>   *	@cred contains the credentials to use.
> + *      @ns contains the user namespace we want the capability in
>   *	@cap contains the capability <include/linux/capability.h>.

That should be tabbed to match the lines either side.

David
