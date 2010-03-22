From: Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
Subject: Re: [C/R v20][PATCH 38/96] c/r: dump open file descriptors
Date: Mon, 22 Mar 2010 17:18:51 -0600
Message-ID: <28C1599C-9EF5-446E-91D3-C4DC7776A913__40974.0105541006$1269299972$gmane$org@sun.com>
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
In-reply-to: <20100322021242.GI2887-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2010-03-21, at 20:12, Matt Helsley wrote:
> These are the same kinds of problems encountered during backup. You
> can play fast and loose -- like taking a backup while everything is
> running -- or you can play it conservative and freeze things.
>
> I think btrfs snapshots are just one possible solution and it's not
> overkill.
>
> For some filesystems it might make sense to use the filesystem  
> freezer to
> ensure that no files are deleted while the backup takes place.  
> Combined
> with tools like rsync or rdiff backup these operations could be low  
> bandwidth
> and low latency if well-known live-migration techniques are used.
>
> Or use dm snapshots.


If you are using snapshots, then even an open-unlinked file will not  
be deleted from the filesystem until it is closed, because the inode  
will still be available on disk even without the filename.  That would  
be a good reason to also store the file handle (e.g. inode+generation  
for simple filesystems) in the checkpoint file, so that you can re- 
open this file by the file handle after the process is restarted.

Since Aneesh is starting to add an interface for this to the kernel  
anyway, I don't think it would be very hard to dump/restore a handful  
of extra bytes with each file.  Conversely, now is the time for  
getting the open-by-handle APIs correct for this code.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
