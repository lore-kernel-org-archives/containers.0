From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Libvirt/LXC/SystemD/SELinux Hackfest at Linux Plumbers, San Diego
Date: Fri, 20 Jul 2012 10:02:34 +0100
Message-ID: <201207200908.q6K98e8O025148@int-mx12.intmail.prod.int.phx2.redhat.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Resent-Message-ID: <20120720090840.GA31929-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Resent-To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Folks,

This years Linux Plumbers Conference (LPC)[1] is taking place in San Diego
in the last week of August (co-located with LinuxCon).

Since there is alot of integration between libvirt / LXC / SystemD and
SELinux, and many of the key developers from those projects will be
at LPC, Lennart proposed we hold a hackfest at LPC on this subject
To quote Lennart's blog[2]:

  "On 28th of August we'll have a hackfest on the topic of closer
   integration of libvirt, LXC, systemd and SELinux, colocated with
   LPC in San Diego, California. We'll have a number of key people
   from these projects participating, including Dan Walsh, Eric Paris,
   Daniel P. Berrange, Kay Sievers and myself.

   Topics we'll cover: making Fedora/Linux boot entirely cleanly in
   normal containers, teaching systemd's control tools minimal
   container-awareness (such as being able to list all services
   of all containers in one go, in addition to those running on
   the host system), unified journal logging across multiple containers,
   the systemd container interface, auditing and containers, running
   multiple instances from the same /usr tree, and a lot more...

   Who should attend? Everybody hacking on the mentioned projects
   who wants to help integrating them with the goal of turning them
   into a secure, reliable, powerful container solution for Linux.

   Who should not attend? If you don't hack on any of these projects,
   or if you are not interested in closer integration of at least two
   of these projects.

   How to register? Just show up. You get extra points however for
   letting us know in advance (just send us an email). Attendance is
   free."

NB, note the date - 28th of August is the Tuesday - ie the day *before*
the main LPC conference programme begins. We have space reserved in
the main hotel for the hackfest on this day.

Regards,
Daniel

[1] http://www.linuxplumbersconf.org/2012/
[2] http://0pointer.de/blog/hackfests.html
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
