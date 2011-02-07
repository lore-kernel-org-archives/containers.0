From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: if you use user namespaces
Date: Mon, 7 Feb 2011 04:18:39 +0000
Message-ID: <20110207041839.GA25871__44326.0125387043$1297052328$gmane$org@mail.hallyn.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Please let me know.  lxc does not use them right now.  Libvirt uses them
for lxc containers f they are available, but I hope we can essentially
have it stop for awhile.  In addition, there's tons of software out
there that I don't know about, and fear of breaking their use of current
user namespaces has been keeping me from pushing further userns patches.

I've outlined how I see user namespaces developing at
https://wiki.ubuntu.com/UserNamespace .  Note there is nothing new
in there - some of it goes a year back, much of it more than two
years.  Nothing actually new.

Currently user namespaces are not very useful, but they do provide
separate uid accounting, and simply tossing CLONE_NEWUSER in with
CLONE_NEWNS and friends has until now been safe to do.  As you can
see, that is going to change.  So if that would cause you pain that
you can't work around, please get back to me.  Otherwise, I'd like
to get serious soon about expanding upon, and pushing upstream, the
patches to make CLONE_NEWUSER more useful for sandboxing.

thanks,
-serge
