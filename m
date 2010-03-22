From: Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>
Subject: Re: [C/R v20][PATCH 38/96] c/r: dump open file descriptors
Date: Mon, 22 Mar 2010 13:51:59 +0000
Message-ID: <20100322135159.GA32588__43331.1638226316$1269265984$gmane$org@shareable.org>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
	<1268960401-16680-4-git-send-email-orenl@cs.columbia.edu>
	<F18D161D-850B-4C82-83D5-1F19D573E84F@sun.com>
	<20100320044310.GC2887@count0.beaverton.ibm.com>
	<20100321172703.GC4174@shareable.org>
	<20100321194019.GA11714@hallyn.com> <4BA68884.3080003@free.fr>
	<20100322021242.GI2887@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100322021242.GI2887-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
List-Id: containers.vger.kernel.org

Matt Helsley wrote:
> These are the same kinds of problems encountered during backup. You
> can play fast and loose -- like taking a backup while everything is
> running -- or you can play it conservative and freeze things.

Not really.  The issue isn't files getting deleted during the checkpoint,
it's files deleted or renamed over _prior_ to beginning checkpoint.

That's a common situation.  For example if someone did a software
package update, you can easily have processes which reference deleted
files running for months.  Same if a program keeps open a data file
which is edited by a text editor, which renames when saving.  Etc,
etc.

> I think btrfs snapshots are just one possible solution and it's not
> overkill.

I don't think btrfs snapshots solves the problem anyway, unless you
also have a way to look up a file by inode number or equivalent, or
the other ideas discussed such as making a link to a deleted file.

Note that it isn't _just_ deleted files.  The name in question may be
deleted but there may still be other links to the file.  Or it could
be opened via different link names, some or all of which have been
deleted or renamed over.

In thoses cases it would be a bug to make a copy of the deleted file
in the checkpoint state, or in the filesystem, as were mentioned
earlier...

> I imagine fanotify could also be useful so long as userspace has marked
> things correctly prior to checkpoint. My high level understanding of
> fanotify was we'd be able to delay (or deny) deletion until checkpoint
> is complete.

Yes, that might be a way to block filesystem changes during
checkpoint, although fanotify's capabilities weren't complete enough
for this, last time I looked.  (It didn't give sufficient information
directory operations.)

-- Jamie
