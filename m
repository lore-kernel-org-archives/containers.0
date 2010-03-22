From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [C/R v20][PATCH 38/96] c/r: dump open file descriptors
Date: Sun, 21 Mar 2010 19:12:42 -0700
Message-ID: <20100322021242.GI2887__13162.2171415531$1269224023$gmane$org@count0.beaverton.ibm.com>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
	<1268960401-16680-4-git-send-email-orenl@cs.columbia.edu>
	<F18D161D-850B-4C82-83D5-1F19D573E84F@sun.com>
	<20100320044310.GC2887@count0.beaverton.ibm.com>
	<20100321172703.GC4174@shareable.org>
	<20100321194019.GA11714@hallyn.com> <4BA68884.3080003@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BA68884.3080003-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Mar 21, 2010 at 09:58:44PM +0100, Daniel Lezcano wrote:
> Serge E. Hallyn wrote:
> > Quoting Jamie Lokier (jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org):
> >   
> >> Matt Helsley wrote:
> >>     
> >>>> That said, if the intent is to allow the restore to be done on
> >>>> another node with a "similar" filesystem (e.g. created by rsync/node
> >>>> image), instead of having a coherent distributed filesystem on all
> >>>> of the nodes then the filename makes sense.
> >>>>         
> >>> Yes, this is the intent.
> >>>       
> >> I would worry about programs which are using files which have been
> >> deleted, renamed, or (very common) renamed-over by another process
> >> after being opened, as there's a good chance they will successfully
> >> open the wrong file after c/r, and corrupt state from then on.
> >>     
> >
> > Userspace is expected to back up and restore the filesystem, for
> > instance using a btrfs snapshot or a simple rsync or tar.
> >
> >   
> That does not solve the problem Jamie is talking about.
> A rsync or a tar will not see a deleted file and using a btrfs to have 
> the CR to work with the deleted files is a bit overkill, no ?

These are the same kinds of problems encountered during backup. You
can play fast and loose -- like taking a backup while everything is
running -- or you can play it conservative and freeze things.

I think btrfs snapshots are just one possible solution and it's not
overkill.

For some filesystems it might make sense to use the filesystem freezer to
ensure that no files are deleted while the backup takes place. Combined
with tools like rsync or rdiff backup these operations could be low bandwidth
and low latency if well-known live-migration techniques are used.

Or use dm snapshots.

I imagine fanotify could also be useful so long as userspace has marked
things correctly prior to checkpoint. My high level understanding of
fanotify was we'd be able to delay (or deny) deletion until checkpoint
is complete.

Or if using fanotify is unacceptable, at the very least we could use
inotify to know when a file needed for restart has been deleted. It might
go something like:

start watching files/dirs needed (fanotify or inotify)
	Delay/deny changes (fanotify ONLY)
freeze tasks for checkpoint
freeze filesystem contents:
	take btrfs snapshots OR
	take dm snapshots OR
	use filesystem freezer OR
backup filesystem contents
sys_checkpoint
check for changes to the filesystem contents and report failure if they
	interfere with restart (inotify ONLY)
thaw filesystem contents
thaw tasks

So there are lots of possible solutions and they don't all involve trying to
stop the whole VFS or the whole machine. They also don't require anything
more in-kernel than what's already being pushed (our patchset, Eric Paris'
patchset for the optional fanotify idea).

> I have another question about the deleted files. How is handled the case 
> when a process has a deleted mapped file but without an associated file 
> descriptor ?

The mapped file holds a struct file reference in the VMA. When checkpoint
walks the VMAs the struct file is visited just like for struct files reached
from file descriptors.

Cheers,
	-Matt Helsley
