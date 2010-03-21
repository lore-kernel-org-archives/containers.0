From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [C/R v20][PATCH 38/96] c/r: dump open file descriptors
Date: Sun, 21 Mar 2010 14:40:19 -0500
Message-ID: <20100321194019.GA11714__13203.2300266021$1269200543$gmane$org@hallyn.com>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
	<1268960401-16680-4-git-send-email-orenl@cs.columbia.edu>
	<F18D161D-850B-4C82-83D5-1F19D573E84F@sun.com>
	<20100320044310.GC2887@count0.beaverton.ibm.com>
	<20100321172703.GC4174@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100321172703.GC4174-yetKDKU6eevNLxjTenLetw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Jamie Lokier (jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org):
> Matt Helsley wrote:
> > > That said, if the intent is to allow the restore to be done on
> > > another node with a "similar" filesystem (e.g. created by rsync/node
> > > image), instead of having a coherent distributed filesystem on all
> > > of the nodes then the filename makes sense.
> > 
> > Yes, this is the intent.
> 
> I would worry about programs which are using files which have been
> deleted, renamed, or (very common) renamed-over by another process
> after being opened, as there's a good chance they will successfully
> open the wrong file after c/r, and corrupt state from then on.

Userspace is expected to back up and restore the filesystem, for
instance using a btrfs snapshot or a simple rsync or tar.

If we detect anything which really is not supported (for instance
inotify for now) then we fail and leave a log message explaining the
failure.

thanks,
-serge
