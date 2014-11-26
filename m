From: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Subject: systemd-cgroups-agent not working in containers
Date: Wed, 26 Nov 2014 22:29:29 +0100
Message-ID: <54764639.3020100@nod.at>
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
To: "systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org" <systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
Cc: "libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, David Gstir <david-S6VGOU4v5edDinCvNWH78Q@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi!

I run a Linux container setup with openSUSE 13.1/2 as guest distro.
After some time containers slow down.
An investigation showed that the containers slow down because a lot of stale
user sessions slow down almost all systemd tools, mostly systemctl.
loginctl reports many thousand sessions.
All in state "closing".

The vast majority of these sessions are from crond an ssh logins.
It turned out that sessions are never closed and stay around.
The control group of a said session contains zero tasks.
So I started to explore why systemd keeps it.
After another few hours of debugging I realized that systemd never
issues the release signal from cgroups.
Also calling the release agent by hand did not help. i.e.
/usr/lib/systemd/systemd-cgroups-agent /user.slice/user-0.slice/session-c324.scope

Therefore systemd never recognizes that a server/session has no more tasks
and will close it.
First I thought it is an issue in libvirt combined with user namespaces.
But I can trigger this also without user namespaces and also with systemd-nspawn.
Tested with systemd 208 and 210 from openSUSE, their packages have all known bugfixes.

Any idea where to look further?
How do you run the most current systemd on your distro?

Thanks,
//richard
