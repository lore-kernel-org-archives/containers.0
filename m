From: Andrian Nord <nightnord-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [lxc-devel] Shutting down a container?
Date: Fri, 13 Nov 2009 23:18:08 +0300
Message-ID: <20091113195229.GA2327@nord.niifaq.ru>
References: <4AFD9031.6030102@msgid.tls.msk.ru>
 <4AFD9E29.1030601@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AFD9E29.1030601-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Nov 13, 2009 at 06:58:01PM +0100, Daniel Lezcano wrote:
> Michael Tokarev wrote:
> >
> > Should there be some different init perhaps, that will
> > exit given some command or signal, instead of sysvinit?
> > Or is there other way to shutdown a container?
> >

There is two techniques, that seems to be 'common':
1) Write your own init script, which would run every process you need
and traping some signal via 'trap' that will exec an shutdown event.
It has big advantage of lower overhead for rc-subsystem, but much more
complicated to maintain.

2) Second technique is to rewrite container's /etc/inittab of sysvinit
to have line like that:
ca:12345:ctrlaltdel:/sbin/shutdown -hP now

This is, obviously, what init should execute on ctrl-alt-del shortcut,
actually triggered by SIGINT signal sent to init process.

So, full-automated solution is
1) find container's init's pid via lxc-ps (speaking of lxc utilities).
2) sed/echo-in container's inittab via /proc/${initpid}/root/etc/inittab
3) kill -INT ${initpid}
4) in loop, until all non-inits are gone:
	take random not-init container process from lxc-ps and 'wait'
	for it's termination.
5) 'kill -9' init, or just 'lxc-stop' container.

Waiting for pid may be problematic, as you may wait only for your child,
but if you'll do this via rc-system, it should work. At least it works
for openrc =)

This is hack, yes, but there is no common way of inserting commands into
container by now (there was such thread into lxc-devel maillist), but
solution is found and needs implementing.

Much worse situation is with syncing start procedure / waiting for
network readyness =).
