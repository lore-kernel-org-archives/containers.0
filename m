From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: [RFC][PATCH 2/5] Container Freezer: Make refrigerator always
	available
Date: Sat, 26 Apr 2008 15:02:36 +0200
Message-ID: <200804261502.37413.rjw__27469.1951148727$1209215040$gmane$org@sisk.pl>
References: <20080424064756.643890130@us.ibm.com>
	<20080425110456.GF14903@elf.ucw.cz> <4811C978.6010508@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4811C978.6010508-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
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
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Friday, 25 of April 2008, Cedric Le Goater wrote:
> Pavel Machek wrote:
> > Hi!
> > 
> >> Now that the TIF_FREEZE flag is available in all architectures,
> >> extract the refrigerator() and freeze_task() from kernel/power/process.c
> >> and make it available to all.
> >>
> >> The refrigerator() can now be used in a control group subsystem 
> >> implementing a control group freezer.
> >>
> >> Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> >> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> >> Tested-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > 
> > There's no problem with doing this... but you should get some debate
> > (with Linus?) whether using freezer for cgroups is sane. 
> 
> Yes that's what we are trying to know, is the fake signal mechanism 
> used by the freezer something we can build upon ? 

Well, currently, the freezer doesn't send fake signals to kernel threads which
turns out to be problematic, becase some kernel threads behave very much like
user space processes (basically, the threads related to NFS and CIFS).

I have an idea how to fix this issue, but I'm not sure if it's acceptable
overall.  I'll try to prepare a patch later today or tomorrow.

Thanks,
Rafael
