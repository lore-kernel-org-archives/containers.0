From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [REVIEW][PATCH 1/3] vfs: In d_path don't call d_dname on a mount
	point
Date: Sat, 30 Nov 2013 06:15:26 +0000
Message-ID: <20131130061525.GY10323@ZenIV.linux.org.uk>
References: <20131116164840.GA4441@mail.hallyn.com>
	<20131117030653.GA7670@mail.hallyn.com>
	<20131118031932.GA17621@mail.hallyn.com>
	<52899D09.5080202@cn.fujitsu.com>
	<20131118140830.GA22075@mail.hallyn.com>
	<20131118180134.GA24156@mail.hallyn.com>
	<87k3g5gnuv.fsf@xmission.com>
	<20131126181043.GA25492@mail.hallyn.com>
	<87siui1z1g.fsf_-_@xmission.com> <8738mi1yya.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8738mi1yya.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

[Eric Dumazet Cc'd since ->d_dname() had been introduced by him]

On Tue, Nov 26, 2013 at 04:16:13PM -0800, Eric W. Biederman wrote:
> >   proc ipc:[4026531839] proc rw,nosuid,nodev,noexec 0 0
> >
> > This breaks userspace which expects the 2nd field in
> > /proc/mounts to be a valid path.
> 
> The symlink /proc/<pid>/ns/{ipc,mnt,net,pid,user,uts} point to
> dentries allocated with d_alloc_pseudo that we can mount, and
> that have interesting names printed out with d_dname.
> 
> When these files are bind mounted /proc/mounts is not currently
> displaying the mount point correctly because d_dname is called instead
> of just displaying the path where the file is mounted.
> 
> Solve this by adding an explicit check to distinguish mounted pseudo
> inodes and unmounted pseudo inodes.  Unmounted pseudo inodes always
> use mount of their filesstem as the mnt_root  in their path making
> these two cases easy to distinguish.

Excuse me, but this is a wrong way to deal with that.  The root of the
problem is your "let's give them ->d_dname() *and* let them live on the
same procfs vfsmount".  The latter, BTW, requires the suckers to access
nd->path.mnt, which is a bad thing by itself.  Plus the wrong way
->d_dname() is called.  It was kinda-sorta defensible back when it
had been introduced, but only because all filesystems with ->d_dname()
had been MS_NOUSER ones.  Kinda-sorta since it introduced an unpleasant
difference in semantics of d_path() and the rest of its ilk - see
e.g. tomoyo calling ->d_dname() manually.

->d_dname() addresses a real need, no arguments here - we do want to
delay name generation for pipes and sockets until asked for it.  The
problem is that it's dealt with in the wrong place - we ought to
have it handled when prepend_path() reaches a vfsmount with no
parent and an IS_ROOT() dentry.  _Then_ we need to check if it has
->d_op->d_dname() and call one if it does.

There's a bunch of unpleasant details around the handling of "what if
the final vfsmount is detached or internal" (and induced weirdness
with d_absolute_path(), etc. callers deciding whether they want to
call ->d_dname() manually, since only d_path() calls it); I'll look into
that.

As for using this procfs vfsmount...  Frankly, I would rather add a mini-fs
a-la aio one and have those inodes live _there_, with the same vfsmount
used for all those guys.  Internal, of course.  Without bothering with
register_filesystem(), with all associated headache ("what if userland
mounts the entire thing", etc.)
