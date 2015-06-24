From: Alexander Larsson <alexl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [ANNOUNCE] xdg-app - desktop app sandboxing system
Date: Wed, 24 Jun 2015 10:15:11 +0200
Message-ID: <1435133711.10746.22.camel__6688.42575182698$1435133738$gmane$org@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: gnome-announce-list-rDKQcyrBJuzYtjvyW6yDsg@public.gmane.org, gnome-os-list-rDKQcyrBJuzYtjvyW6yDsg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xdg <xdg-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
List-Id: containers.vger.kernel.org

xdg-app is a desktop and distribution-independent application bundling
and system for Linux. It uses user namespaces and the kernel container
technologies to run applications in a sandboxed environment without any
kind of root privileges or setuid required[1]. It also features a user
-space dbus filter with policies that are compatible with kdbus.

xdg-app is still somewhat early in development, but it is now in a
state where it is stable enough to get a wider audience.

More details on how xdg-app works can be found here:
 https://wiki.gnome.org/Projects/SandboxedApps

xdg-app recently moved to a new hosting service at freedesktop.org, so
these are the current resources for xdg-app:

  Mailing list: http://lists.freedesktop.org/mailman/listinfo/xdg-app
  IRC: #xdg-app on freenode
  Git: git://anongit.freedesktop.org/xdg-app/xdg-app
  Releases: http://www.freedesktop.org/software/xdg-app/releases/
  Bugzilla: https://bugs.freedesktop.org/ (product xdg-app)

To actually test xdg-app I have created upstream gnome and freedesktop 
runtimes with some test apps, as well as an example repository with
runtime and apps based on fedora rawhide packages. See these blog posts
for details:
 https://blogs.gnome.org/alexl/2015/03/31/official-gnome-sdk-runtime-builds-are-out/
 https://blogs.gnome.org/alexl/2015/06/17/testing-rawhide-apps-using-xdg-app/

[1] Needs user namespaces in the kernel, if not available it can be
built to use setuid or setcaps instead.


-- 
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Alexander Larsson                                            Red Hat, Inc 
       alexl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org            alexander.larsson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org 
He's an impetuous playboy rock star with a robot buddy named Sparky. 
She's a disco-crazy impetuous schoolgirl with her own daytime radio talk 
show. They fight crime! 
