From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: kernel summit topic - 'containers end-game'
Date: Tue, 23 Jun 2009 09:56:11 -0500
Message-ID: <20090623145611.GB19332@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Daniel Veillard <veillard-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

A topic on ksummit agenda is 'containers end-game and how do we
get there'.

So for starters, looking just at application (and system) containers, what do
the libvirt and liblxc projects want to see in kernel support that is currently
missing?  Are there specific things that should be done soon to make containers
more useful and usable?

More generally, the topic raises the question... what 'end-games' are there?
A few I can think of off-hand include:

	1. resource control
	2. lightweight virtual servers
	3. (or 2.5) unprivileged containers/jail-on-steroids
		(lightweight virtual servers in which you might, just
		maybe, almost, be able to give away a root account, at
		least as much as you could do so with a kvm/qemu/xen
		partition)
	4. checkpoint, restart, and migration

For each end-game, what kernel pieces do we think are missing?  For instance,
people seem agreed that resource control needs io control :)  Containers imo
need a user namespace.  I think there are quite a few network namespace
exploiters who require sysfs directory tagging (or some equivalent) to
allow us to migrate physical devices into network namespaces.  And
checkpoint/restart needs... checkpoint/restart.

thanks,
-serge
