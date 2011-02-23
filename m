From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 1/9] Add a user_namespace as creator/owner of uts_namespace
Date: Wed, 23 Feb 2011 15:54:12 -0800
Message-ID: <m162sagvdn.fsf__35551.6659481966$1298505384$gmane$org@fess.ebiederm.org>
References: <m1lj16ih0n.fsf@fess.ebiederm.org>
	<20110217150257.GA26395@mail.hallyn.com>
	<20110217150224.GA26334@mail.hallyn.com> <3139.1298481393@redhat.com>
	<8559.1298503148@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8559.1298503148-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (David Howells's message of "Wed, 23
	Feb 2011 23:19:08 +0000")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
>> > Which means that unless the uts_namespace belongs to our user_namespace, we
>> > cannot change it.  Is that correct?
>> 
>> No.  If you are root in a parent namespace you can also change it.
>
> But surely, by definition, if you're a user in this namespace, you can't also
> be root in a parent namespace...

To be clear the case you looked at was:

> -	if (!capable(CAP_SYS_ADMIN))
> +	if (!ns_capable(current->nsproxy->uts_ns->user_ns, CAP_SYS_ADMIN))
> 
> what is it you're actually asking?  I presume it's 'does this user have
> CAP_SYS_ADMIN capability over objects belonging to the uts_namespace's
> user_namespace?'

Here "current->nsproxy->uts_ns->user_ns" (the target_ns value) is only
refers to the uts_ns we are talking about.

The user itself comes from current_user().

> For the case I worked through current_user() is a member of current_user_ns()
> and can't also be a member of its parent, grandparent, etc. - or can
> it?

Right now if you are looking at current_user() because of limitations in
the creation ordering I think you are correct. 

However in the near term pile of changes to merge, are the syscalls for
joining an existing namespace.  At which point there is no reason in
general to suppose the current limitations of creation apply.

Although it is conceivable that unshare of namespaces can also get you
to someplace similar to joining prexisting namespaces.

Eric
