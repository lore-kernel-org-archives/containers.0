From: Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>
Subject: Re: [C/R v20][PATCH 38/96] c/r: dump open file descriptors
Date: Mon, 22 Mar 2010 02:20:03 +0000
Message-ID: <20100322022003.GA16462__5097.30503331429$1269224447$gmane$org@shareable.org>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
	<1268960401-16680-4-git-send-email-orenl@cs.columbia.edu>
	<F18D161D-850B-4C82-83D5-1F19D573E84F@sun.com>
	<20100320044310.GC2887@count0.beaverton.ibm.com>
	<20100321172703.GC4174@shareable.org>
	<20100322010606.GG2887@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100322010606.GG2887-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
> On Sun, Mar 21, 2010 at 05:27:03PM +0000, Jamie Lokier wrote:
> > Matt Helsley wrote:
> > > > That said, if the intent is to allow the restore to be done on
> > > > another node with a "similar" filesystem (e.g. created by rsync/node
> > > > image), instead of having a coherent distributed filesystem on all
> > > > of the nodes then the filename makes sense.
> > > 
> > > Yes, this is the intent.
> > 
> > I would worry about programs which are using files which have been
> > deleted, renamed, or (very common) renamed-over by another process
> > after being opened, as there's a good chance they will successfully
> > open the wrong file after c/r, and corrupt state from then on.
> 
> The code in the patches does check for unlinked files and refuses
> to checkpoint if an unlinked file is open. Yes, this limits the usefulness
> of the code somewhat but it's a problem we can solve and c/r is still quite
> useful without the solution.
> 
> We've done our best to try and reach that ideal. You're welcome to have a
> look at the code to see if you can find any ways in which we haven't.
> Here's the code that refuses to checkpoint unsupported files. I think
> it's pretty easy to read:

From a very quick read, 

>         if (d_unlinked(file->f_dentry)) {
>                 ckpt_err(ctx, -EBADF, "%(T)%(P)Unlinked files unsupported\n",
>                          file);

Hmm.

I wonder if d_unlinked() is always true for a file which is opened,
unlinked or renamed over, but has a hard link to it from elsewhere so
the on-disk file hasn't gone away.

I guess it probably is.  That's kinda neat!  I'd hoped there would be a
good reason for f_dentry eventually ;-)

What about files opened through /proc/self/fd/N before or after the
original file was unlinked/renamed-over.  Where does the dentry point?

-- Jamie
