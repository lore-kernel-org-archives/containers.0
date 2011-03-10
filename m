From: "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: 2011 LXC development mini-conf?
Date: Thu, 10 Mar 2011 10:30:35 -0600
Message-ID: <20110310163035.GA15508@peq.hallyn.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, zulcss-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, erkan yanar <erkan.yanar-z+G3R6qIeCAZId6A0yLOdQ@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Dave Walker <davewalker-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, "Trent W. Buck" <twb-3AaVwj9c10wJYc8buCWFOBCuuivNXqWP@public.gmane.org>, stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

Hi, I'm sending this email to gauge interest in a lxc development
mini-conf this summer.  Last year we had many lxc sessions at the
Ubuntu Developer Conference.  I'm all for doing that again, but
while that gives us 'free' scheduling and logistics and a nice focus
on realistic short-term development goals, I fear making it seem
like ubuntu is trying to hijack lxc, and I don't want to make people
on fedora, gentoo, etc to feel there is a barrier to their
attending (*).  Erkan suggested froscon (http://www.froscon.de/), in
Germany Aug 20-21, as a potential site.

If you're interested in attending and that location is ok with
you, please let me know.  If you're interested in attending and
you'd like to suggest another location, please do so.

The focus of the mini-conf is simple: improve LXC.  That means
the lxc toolsuite itself, kernel features exploitable by lxc,
and system management and integration of lxc.

Below is a start to a potential topic list.  If we were to turn
part of this into a hack-fest, we could probably pound out some
of these right there on site.  I think I like the idea of doing
a half day to go over the topics list - write down who is
interested in doing what and who may have tried/started some
of these before, then spend a day (while intermingling with
froscon) hacking, then a half-day wrapup.  That's just a suggestion
though, and perhaps too unorthodox of one.

Potential topics:
	landscape of current (and likely/hopeful) lxc users and use-cases
		to help prioritize development
	container reboot and shutdown
	per-container dmesg
	user namespaces
	lxc LSM integration
	libvirt
		Serge never wrote the libvirt-lxc wrapper driver
		Sentiment is that libvirt should handle container auto-start and networking
		(Some might argue that)
		Discuss
	container startup debugging
		typical irc 'help' converstations suggest there is a problem
	management interface
		curses-based
		other
	udev and device namespaces
		to prevent udev storms on device hotplug
	checkpoint/restart

thanks,
-serge

(*) There still will be LXC sessions at UDS this May, and I highly
encourage developers and users of/on other distros to attend, if only,
as I will be, online.
