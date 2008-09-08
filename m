From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v3][PATCH 8/9] File descriprtors (dump)
Date: Mon, 08 Sep 2008 09:57:42 -0700
Message-ID: <1220893062.23386.176.camel__1139.75013741783$1220893210$gmane$org@nimitz>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0809040405250.5982@takamine.ncl.cs.columbia.edu>
	<1220553660.23386.60.camel@nimitz> <48C35DFC.9080903@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48C35DFC.9080903-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, 2008-09-07 at 00:52 -0400, Oren Laadan wrote:
> >> +	for (i = 0; i < fdt->max_fds; i++) {
> >> +		if (!fcheck_files(files, i)
> >> 			continue;
> >> 		if (n == max) {
> >> +			spin_unlock(&files->file_lock);
> >> +			kfree(fdlist);
> >> +			max *= 2;
> >> +			if (max < 0) {	/* overflow ? */
> >> +				n = -EMFILE;
> >> +				break;
> >> +			}
> >> +			goto repeat;
> >> +		}
> >> +		fdlist[n++] = i;
> >> +	}
> > 
> > My gut also says that there has to be a better way to find a good size
> > for fdlist() than growing it this way.  
> 
> Can you suggest a better way to find the open files of a task ?
> 
> Either I loop twice (loop to count, then allocate, then loop to fill),
> or optimistically try an initial guess and expand on demand.

I'd suggest the double loop.  I think it is much more straightforward
code.

> >> +	hh->f_version = file->f_version;
> >> +	/* FIX: need also file->f_owner */
> >> +
> >> +	switch (inode->i_mode & S_IFMT) {
> >> +	case S_IFREG:
> >> +		fd_type = CR_FD_FILE;
> >> +		break;
> >> +	case S_IFDIR:
> >> +		fd_type = CR_FD_DIR;
> >> +		break;
> >> +	case S_IFLNK:
> >> +		fd_type = CR_FD_LINK;
> >> +		break;
> >> +	default:
> >> +		return -EBADF;
> >> +	}
> > 
> > Why don't we just store (and use) (inode->i_mode & S_IFMT) in fd_type
> > instead of making our own types?
> 
> There will be others that cannot be inferred from inode->i_mode,
> e.g. CR_FD_FILE_UNLINKED, CR_FD_DIR_UNLINKED, CR_FD_SOCK_UNIX,
> CR_FD_SOCK_INET_V4, CR_FD_EVENTPOLL etc.

I think we have a basically different philosophy on these.  I'd say
don't define them unless absolutely necessary.  The less you spell out
explicitly, the more flexibility you have in the future, and the less
code you spend doing simple conversions.

Anyway, I see why you're doing it this way.

-- Dave
