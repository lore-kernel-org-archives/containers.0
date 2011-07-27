From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/7 + tools] Checkpoint/restore mostly in the
	userspace
Date: Tue, 26 Jul 2011 17:53:41 -0700
Message-ID: <20110727005341.GB15501@count0.beaverton.ibm.com>
References: <4E204466.8010204@parallels.com>
	<20110723002558.GE16940@count0.beaverton.ibm.com>
	<CAOS58YPqLSYi2xECUk4O5GG3s6aokT=VykmkL6UnAOzyHXNAgQ@mail.gmail.com>
	<20110726225911.GF14808@count0.beaverton.ibm.com>
	<20110726234657.GD28497@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110726234657.GD28497-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Jul 27, 2011 at 01:46:57AM +0200, Tejun Heo wrote:
> Hello,
> 
> On Tue, Jul 26, 2011 at 03:59:11PM -0700, Matt Helsley wrote:
> > > /proc/PID/fd already provides access to deleted files perfectly well
> > > as most avid p0rn watchers would know (you can run mplayer on flash's
> > > deleted temp files). ;)
> > 
> > Yup, access to the unlinked file contents. This is an example where
> > things appear simple and complete in /proc yet it is insufficient.
> > Here's what you'll need:
> > 
> > The string "(deleted)" in a file name is, strictly speaking, ambiguous --
> > it does not mean the file is unlinked. You also can't infer that it is
> > unlinked by stat()'ing that path since a different file could have
> > been created in the same spot. For something unambiguous you'll
> > have to add that information to /proc somewhere. fdinfo doesn't seem
> > to be the right place since fds aren't unlinked -- files are. 
> 
> Hmm... but wouldn't fstat() after open reveal the original inode?  ie.
> 
>   $ cat fstat.c
>   #include <sys/types.h>
>   #include <sys/stat.h>
>   #include <unistd.h>
>   #include <stdio.h>
>   #include <fcntl.h>
>   #include <assert.h>
> 
>   int main(int argc, char **argv)
>   {
> 	  int fd;
> 	  struct stat st = {};
> 
> 	  assert((fd = open(argv[1], O_RDONLY)) >= 0);
> 	  assert(!fstat(fd, &st));
> 	  printf("ino=%lu nlink=%lu\n",
> 		 (unsigned long)st.st_ino, (unsigned long)st.st_nlink);
> 	  return 0;
>   }
>   $ gcc -Wall -o fstat fstat.c
>   $ cat > asdf &
>   [7] 31908
>   $ ./fstat asdf
>   ino=9180912 nlink=1
>   $ ./fstat /proc/31908/fd/1
>   ino=9180912 nlink=1
>   $ rm -f asdf
>   $ ./fstat /proc/31908/fd/1
>   ino=9180912 nlink=0
>   $ touch asdf
>   $ $ ./fstat asdf
>   ino=9180915 nlink=1
> 
> I don't think anything is ambiguous.

Good point. Hmm, is it possible nlink could change to/from 0 in some obscure
VFS code though? The cgroup freezer won't cover filesystem activity so
checkpoint would also have to freeze the filesystem using the fs
freezer..

Though with flink() a link count race like that probably wouldn't matter.

> 
> > Then you've got to detect when they're the same unlinked file and share
> > the copy upon restart. Or they could be different unlinked files
> > with the same path in which case you should not share the copy. I suppose
> > you'll have to check the device and inode and then see if any other task
> > being checkpointed has it open... once for each of potentially thousands
> > of fds being checkpointed.
> 
> Just build a hash table w/ fstat results.  It's O(nr_open_files)
> whether you do that or not.

Yup. Still, it would be great if there was some way to avoid the need
for a hash table.

> 
> > Then there's the case where you've got one unlinked dentry for the
> > file but a hardlink elsewhere. The /proc/PID/fd path won't point to the
> > hardlinked location. So in order for those to be the same file upon
> > restart you need to find the file somehow during checkpoint and/or
> > restart.
> 
> You can determine whether search for another hardlink is necessary by
> looking at nlink.  Hmm... I wonder whether open_by_handle_at() can be
> used for this instead of scanning filesystem for matching inode
> number.  Screening by nlink should eliminate most cases but if
> open_by_handle_at() can deal with actual cases, it would be much
> better.

I briefly considered that and it might still be a good idea.
One reason I still went with relink is I was uncertain about what happens
to handles if the kernel reboots. If they become invalid then they don't
seem like a good candidate for checkpointing unlinked files.

> > Finally these files often can be huge. Copying them elsewhere is a huge IO
> > burden compared to careful relinking of the file. IO that could be better
> > spent doing actual work.
> >
> > We solved all that with "relinking". It's possible to make a relink()
> > syscall. The code I posted some time ago to containers@ can be easily
> > adapted for that -- I did so for my testing of those patches. I'm not
> > exactly sure how it would be done from userspace but I suspect it could
> > be done.
> 
> Yeah, something like flink (like fstat for stat) should do it.  FS
> methods operate on dentries anyway so it can be added in the vfs layer
> proper if necessary.

Exactly. I worked on that for a little bit but the security questions
worried me and I haven't picked it back up since. If you or Pavel do pick
up the flink() solution I'd be happy to help review it since it'll probably
be something we can use too.

Cheers,
	-Matt Helsley
