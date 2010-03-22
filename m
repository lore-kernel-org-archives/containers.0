From: Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>
Subject: Re: [C/R v20][PATCH 38/96] c/r: dump open file descriptors
Date: Mon, 22 Mar 2010 14:13:04 +0000
Message-ID: <20100322141304.GB32588__20330.3496273749$1269267296$gmane$org@shareable.org>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
	<1268960401-16680-4-git-send-email-orenl@cs.columbia.edu>
	<F18D161D-850B-4C82-83D5-1F19D573E84F@sun.com>
	<20100320044310.GC2887@count0.beaverton.ibm.com>
	<20100321172703.GC4174@shareable.org>
	<20100322010606.GG2887@count0.beaverton.ibm.com>
	<20100322022003.GA16462@shareable.org>
	<20100322033724.GA20796@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100322033724.GA20796-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Matt Helsley wrote:
> > I wonder if d_unlinked() is always true for a file which is opened,
> > unlinked or renamed over, but has a hard link to it from elsewhere so
> > the on-disk file hasn't gone away.
> 
> Well, if the on-disk file hasn't gone away due to a hardlink then we
> won't need to save the file in the checkpoint image -- the filesystem
> content backup done during checkpoint should also get the file contents.

When that happens, how do you open the correct file on restart?  You
don't know the other link names unless you scan the entire filesystem.
Is that done?

> > I guess it probably is.  That's kinda neat!  I'd hoped there would be a
> > good reason for f_dentry eventually ;-)
> > 
> > What about files opened through /proc/self/fd/N before or after the
> > original file was unlinked/renamed-over.  Where does the dentry point?
> 
> Before the unlink it will result in the same file being opened. If it's
> opened by a task being checkpointed then we'll be in the same situation
> as the "self" task. If it's opened by a task not being checkpointed then
> the "leak detection" code will notice that there's an unaccounted reference
> to the file and checkpoint will fail.

In a nutshell, is that: If you have a filp (open file pointer
(i.e. including seek position)) which is shared between a task which
is checkpointed and a task which isn't checkpointed, that is the
unaccounted reference and will fail?  E.g. as you might get with
dup+fork or AF_LOCAL descriptor passing?

Assuming yes, that has nothing specific to do with /proc.  My question
about /proc was just about whether the newly open file shares the
dentry or gets a new one, I suppose.

Note that...

> So that hopefully addresses your questions regarding the use of the symlinks
> before the unlink.
> 
> After the unlink those symlinks are broken since they have "(deleted)"
> appended.

...the "links" in /proc/N/fd/ are *not* real symlinks, and opening then
does not use the text returned by readlink().

The "(deleted)" text doesn't stop them from being opened after they
are unliked or renamed over (and it certainly doesn't try to open a
file with " (deleted)" in the name :-).

> As with relinking, we need a good way to do the "temporary location".
> That is complicated because we need to choose a location that we have
> permission to write to, always exists during restart, and is guaranteed
> not to have files in it. Relinking the file shifts these problems from
> restart to checkpoint.

It also breaks programs which expect fstat() to always return the same
st_ino while a file is open.  Even FAT guarantees that, I think :-)
Can't win them all :-)

-- Jamie
