From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 11/11][v15]: Document sys_eclone
Date: Tue, 6 Jul 2010 08:12:17 -0500
Message-ID: <20100706131217.GA6175@hallyn.com>
References: <1278189164-28408-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1278189164-28408-12-git-send-email-sukadev@linux.vnet.ibm.com>
	<AANLkTinM1jqG-9Mgbzft8bALGri7ZpzU9ZcPbMTe4fvW@mail.gmail.com>
	<20100704233951.GK3338@count0.beaverton.ibm.com>
	<4C315D2D.6000107@cs.columbia.edu>
	<AANLkTinr_2u-_0S2UvMDc7hOE_JOVIOjGtVo9Tzuk21E@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTinr_2u-_0S2UvMDc7hOE_JOVIOjGtVo9Tzuk21E-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Albert Cahalan <acahalan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Albert Cahalan (acahalan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> On Mon, Jul 5, 2010 at 12:18 AM, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:
> > Finally, there have been objections before to allow pid-selection
> > by non-privileged process.
> 
> Eh, I dearly hope that privileged processes are generally not
> even addressable (never mind creatable or accessable) from
> inside anything other than the top-level pid namespace.

If a privileged task was created in the top-level pid namespace,
then it is not addressable from inside a descendent pid namespace.

> Well, at least nothing should get more privilege than PID 1.
> This would include having UID values that PID 1 can switch
> to and having capability sets that PID 1 can switch to, and
> any other (SE Linux, AppArmor, etc.) things too.

IIUC the spirit of what you say here is what is intended by
the completion of the user namespaces.  They'll ensure that
things like setuid-root and file capabilities limit privilege
to resources owned by the task which created the namespace.

That's why unprivileged pid ns unsharing won't be considered
until user namespaces are completed.

> Restarting a privileged process with a less privileged PID 1
> should result in privilege loss, and ought to require some sort of
> "--force" option to ensure the person accepts possible breakage.

Interesting point.  Do we allow ptrace of a container init?

-serge
