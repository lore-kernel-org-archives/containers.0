From: Martin Pitt <mpitt-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
Subject: Re: [systemd-devel] systemd-cgroups-agent not working in containers
Date: Fri, 28 Nov 2014 06:33:02 +0100
Message-ID: <20141128053302.GA2842__4346.78553506291$1417153365$gmane$org@piware.de>
References: <54764639.3020100@nod.at>
	<CALZWFRLVDW2fL_G0rC6mhMsBTPxsxYF1FATA1j-0unCS8WKAsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALZWFRLVDW2fL_G0rC6mhMsBTPxsxYF1FATA1j-0unCS8WKAsg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cameron Norman <camerontnorman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: "libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org
List-Id: containers.vger.kernel.org

Hello all,

Cameron Norman [2014-11-27 12:26 -0800]:
> On Wed, Nov 26, 2014 at 1:29 PM, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org> wrote:
> > Hi!
> >
> > I run a Linux container setup with openSUSE 13.1/2 as guest distro.
> > After some time containers slow down.
> > An investigation showed that the containers slow down because a lot of stale
> > user sessions slow down almost all systemd tools, mostly systemctl.
> > loginctl reports many thousand sessions.
> > All in state "closing".
> 
> This sounds similar to an issue that systemd-shim in Debian had.
> Martin Pitt (helps to maintain systemd in Debian) fixed that issue; he
> may have some ideas here. I CC'd him.

The problem with systemd-shim under sysvinit or upstart was that shim
didn't set a cgroup release agent like systemd itself does. Thus the
cgroups were never cleaned up after all the session processes died.
(See 1.4 on https://www.kernel.org/doc/Documentation/cgroups/cgroups.txt
for details)

I don't think that SUSE uses systemd-shim, I take it in that setup you
are running systemd proper on both the host and the guest? Then I
suggest checking the cgroups that correspond to the "closing" sessions
in the container, i. e. /sys/fs/cgroup/systemd/.../session-XX.scope/tasks.
If there are still processes in it, logind is merely waiting for them
to exit (or set KillUserProcesses in logind.conf). If they are empty,
check that /sys/fs/cgroup/systemd/.../session-XX.scope/notify_on_release is 1
and that /sys/fs/cgroup/systemd/release_agent is set?

Martin

-- 
Martin Pitt                        | http://www.piware.de
Ubuntu Developer (www.ubuntu.com)  | Debian Developer  (www.debian.org)
