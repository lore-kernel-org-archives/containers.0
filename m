From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [Announce] Checkpoint-restore tool v0.2
Date: Thu, 20 Sep 2012 14:16:16 +0400
Message-ID: <505AECF0.6070607@parallels.com>
References: <500D09C9.7060903@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <500D09C9.7060903-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, lwn-T1hC0tSOHrs@public.gmane.org, "criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: users-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, cgroups mailinglist <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi!

I'm happy to announce that the next big step is done by the CRIU project.

The major achievement so far -- the tool can now dump and restore a simple LXC
container. Another notable feature is the initial support for PTYs which is enough
to play with c/r of a container with active ssh sessions from outside, or with
a screen app with some simple stuff running inside.

A HOWTO describing an LXC container dump and restore is at http://criu.org/LXC


The v0.2 can be downloaded from

	http://download.openvz.org/criu/crtools-0.2.tar.bz2


Other project resources are

  documentation and news:             http://criu.org
  mainling list:                      https://openvz.org/mailman/listinfo/criu
  git repo:                           http://git.criu.org/?p=crtools.git
  kernel with not-yet-merged patches: https://github.com/cyrillos/linux-2.6.git

Thanks,
Pavel
