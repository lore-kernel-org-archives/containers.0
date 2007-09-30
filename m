From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 01/29] task containersv11 basic task container framework
Date: Sun, 30 Sep 2007 02:03:30 -0700
Message-ID: <20070930020330.6bd34dd4.akpm@linux-foundation.org>
References: <20070911195239.997111000@menage.corp.google.com>
	<20070911200144.779221000@menage.corp.google.com>
	<20070929214043.57e9cc39.pj@sgi.com>
	<6599ad830709300010xda1e97cp8c569ce08a87a86b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830709300010xda1e97cp8c569ce08a87a86b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: dev-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, 30 Sep 2007 00:10:18 -0700 "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> On 9/29/07, Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> wrote:
> > Paul M:
> >
> > This patch doesn't build for me in the following case.  If I apply the
> > rest of the containersv11 patches, it builds, but if I happen to bisect
> > into this set of patches having applied only:
> 
> These patches weren't the normal style of incremental patchset - they
> were direct substitutions of the previous patches in Andrew's -mm
> tree.
> 
> Andrew's approach when encountering patches that are, e.g. missing
> includes on some architectures, is to add a *-fix.patch to the series;
> in this case it looks as though the fix for the missing ia64 include
> was added towards the end of the series rather than directly after the
> patch that needed it.

It makes my poor little life heaps easier if people can refer to patches
via their original Subject: or, better, their filename in the -mm patch
series.

I have vague memories that one of the container/cgroup fixup patches was a
bit of a jumbo patch which intersected multiple preceding patches.  Often I
will refactor such a patch into several little *-fix.patch patches so that
everything lands nicely, but this time it was all too much effort and I
just jammmed <whichever patch it was> onto the tail of the queue.

And I think that's OK, because we don't care about git bisectability with
CONFIG_CGROUPS=y (I think?) Anyone who is bisecting through the middle of
the containers patch series is not searching for a containers problem, so
they can just configure it all off.

If we broke the build when CONFIG_CGROUPS=n then yeah, that's a problem.


wrt Paul's observation:

> ... also ... too bad the names of these patches all have 'container' in
> them, not 'cgroup'.  I realize how this came to be, due to changing
> container to cgroup after these patches were named, but it sure would
> be nice if the final patch set record that gets layed down in Linus's
> history showed the correct name of 'cgroup' in these patch names.

that'll be OK.  The "task-containers" text appears only in the filenmaes in
the -mm patch series.  Those filenames don't make an appearance in the git
tree at all, so I didn't bother renaming all the files.


> Hence the fact that you couldn't compile until
> that later patch had been pushed.
> 
> Andrew, is it practical for you to collapse any *-fix.patch files for
> cgroups into the appropriate patches that they fix? That would
> simplify the patch set a bit.

Yep, I always do that prior to sending to Linus, so everything hits the git
tree as nicely as possible.

I normally defer that patch-folding exercise until the last minute, but I
will occasionally do a big fold-some-patches-together pass, just to reduce
the plain number of patches which I'm carrying.  It gets irritating when
this:


box:/usr/src/25> grep foo patches/*
zsh: argument list too long: grep

happens.
