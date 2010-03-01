From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Mon, 01 Mar 2010 13:42:10 -0800
Message-ID: <m1ljebwwgd.fsf__12593.6752105646$1267479828$gmane$org@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <m1wry46es9.fsf@fess.ebiederm.org>
	<1266931623.3973.643.camel@bigi> <m1iq9ocafv.fsf@fess.ebiederm.org>
	<1266934817.3973.654.camel@bigi> <m1r5obbu2w.fsf@fess.ebiederm.org>
	<1266966581.3973.675.camel@bigi> <m1pr3t2fvl.fsf_-_@fess.ebiederm.org>
	<4B883987.6090408@parallels.com> <m1bpfbwuze.fsf@fess.ebiederm.org>
	<4B883E6F.1060907@parallels.com> <m13a0nwu6p.fsf@fess.ebiederm.org>
	<4B88D80A.8010701@parallels.com> <m1mxyvrqvk.fsf@fess.ebiederm.org>
	<4B88E431.6040609@parallels.com> <m1bpfbqajn.fsf@fess.ebiederm.org>
	<4B894564.7080104@parallels.com> <m1iq9io5sc.fsf@fess.ebiederm.org>
	<4B89727C.9040602@parallels.com> <m1ljeempk6.fsf@fess.ebiederm.org>
	<4B8AE8C1.1030305@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B8AE8C1.1030305-GANU6spQydw@public.gmane.org> (Daniel Lezcano's message of "Sun\,
	28 Feb 2010 23\:05\:53 +0100")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
List-Id: containers.vger.kernel.org

Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> writes:

> I agree with all the points you and Pavel you talked about but I don't feel
> comfortable to have the current process to switch the pid namespace because of
> the process tree hierarchy (what will be the parent of the process when you
> enter the pid namespace for example). What is the difference with the sys_bindns
> or the sys_hijack, proposed a couple of years ago ?

I think what has changed is:
- We have mostly completed most of the namespace work.
- We have operational experience with the current namespaces.
- We have people not in the core containers group feeling the pain
  of not having some of these features.

So I think we are at point where we can perhaps talk about these
things and finally solve some of these issues.

Clearly how to enter a container is on your and Pavel's mind as big
concerns.  I am aiming a little lower.

I am of two mind about my patches.  Right now they are a brilliant
proof of concept that we can name namespaces without needing a
namespace for the names of namespaces, and start to be a practical
solution to the join problem.   At the same time, I'm not certain
I like a solution that requires yet more syscalls so I ask myself
is there not yet a simpler way.

Hopefully we can resolve something before the next merge window.

Eric
