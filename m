From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: User namespaces and keys
Date: Wed, 23 Feb 2011 06:46:00 -0800
Message-ID: <m1fwreu7vb.fsf__31752.508521504$1298472529$gmane$org@fess.ebiederm.org>
References: <20110217150224.GA26334@mail.hallyn.com>
	<29677.1298462729@redhat.com> <20110223135814.GA1859@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110223135814.GA1859-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Wed, 23 Feb 2011 13:58:14 +0000")
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting David Howells (dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
>> 
>> I guess we need to look at how to mix keys and namespaces again.
>
>>From strictly kernel pov, at the moment, keys are strictly usable only
> by the user in your own user namespace.
>
> We may want to look at this again, but for now I think that would be a
> safe enough default.  Later, we'll probably want the user creating a
> child_user_ns to allow his keys to be inherited by the child user_ns.
> Though, as I type that, it seems to me that that'll just become a
> maintenance pain, and it's just plain safer to have the user re-enter
> his keys, sharing them over a file if needed.
>
> I'm going to not consider the TPM at the moment :)
>
>> Possibly the trickiest problem with keys is how to upcall key construction to
>> /sbin/request-key when the keys may be of a different user namespace.
>
> Hm, jinkeys, yes.

Serge short term this is where I think we need to add a check or two so
that keys only work in the init_user_ns.  When the rest of the details
are sorted out we can open up the use of keys some more.

As the first stage of converting the network stack we added patches
that turned off everything in non init namespaces.   Those patches
were trivial and easy to review, and it made the conversion process
a lot easier.  I suspect for keys and possibly security modules and
anything else that does is related we want to turn off by default.

Then once the core of user namespaces is safe to unshare without
privilege we can come back and get the more difficult bits.

Eric
