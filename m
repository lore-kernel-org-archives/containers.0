From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] The control group itself
Date: Sat, 23 Feb 2008 15:12:59 -0800
Message-ID: <6599ad830802231512t20343cabq738df3039c8a1d1f@mail.gmail.com>
References: <47AAFFF2.9030804@openvz.org> <47AB013B.8060502@openvz.org>
	<6599ad830802211247t21fdc4e4hfe637fcffd98ded7@mail.gmail.com>
	<47BE83FD.7060908@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47BE83FD.7060908-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Feb 22, 2008 at 12:12 AM, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
>
>  Hmm, you mean make them a binary files?

No, not by default. But I'm working on a plan to have an optional
binary API to cgroups, that would allow multiple control files to be
read in a binary format with a single system call. The existing API
would still be available as well, of course. The idea would be that
monitoring programs that frequently read lots of values from a single
cgroup (or even multiple cgroups) would be able to do so more cheaply
than by making multiple different reads on different files.

In order for this to work, CGroups needs to know the data type of a
given control file - so this would only be available for the control
files that use typed cgroup output methods rather than the raw file
output interface.

>  I thought that filesystem-based
>  API should be human readable and writable as much as possible...
>

Yes, but even without a binary API it makes sense for values that are
likely to be parsed by programs be in a consistent format.

But after thinking more about this, I think that the devices
permission control file output doesn't really fall under this category
- from a programmatic point of view, I suspect it's write-only, and
only humans will be reading the output, for debugging.

Paul
