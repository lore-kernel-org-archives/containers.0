From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: ioctl CAP_LINUX_IMMUTABLE is checked in the wrong namespace
Date: Wed, 30 Apr 2014 13:33:48 +0000
Message-ID: <20140430133348.GB29994@ubuntumail>
References: <20140429183534.GB19325@thunk.org>
	<20140429185251.GA27969@ubuntumail> <53601E5B.5050004@1h.com>
	<20140429220234.GC28410@ubuntumail> <536026B3.1020905@1h.com>
	<20140429222913.GD28410@ubuntumail> <53602B84.1020304@mit.edu>
	<20140430001641.GA28969@ubuntumail>
	<20140430003236.GA6472@thunk.org>
	<87ha5bntqm.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87ha5bntqm.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org> writes:
> 
> > On Wed, Apr 30, 2014 at 12:16:41AM +0000, Serge Hallyn wrote:
> >> I forget the details, but there was another case where I wanted to
> >> have the userns which 'owns' the whole fs available.  I guess we'd
> >> have to check against that instead of using inode_capable.
> >
> > Yes, that sounds right.
> >
> > And *please* tell me that that under no circumstances can anyone other
> > than root@init_user_ns is allowed to use mknod....
> 
> Nope.  mknod not allowed.  capable(CAP_MKNOD) is required is required
> and I can't see any reason to change that.
> 
> As a rule of thumb, the only additional actions allowed in a user
> namespace above and beyond what an ordinary unpriviliged user would be
> allowed to do are those things which we only don't allow because they
> could confuse a setuid root executable.
> 
> 
> If we ever allow the creation of immutable files by unprivileged users
> those files would at least have to be kept completely separate from the
> files the global root encounters (aka a disjoint mount namespace).
> 
> I do not currently see a path to safely using immutable files with just
> user namespace root permission.

It's very far off, but I think the path is:

1. at first mount of a blockdev, note the cred (or just userns) which
mounted it
2. work on auditing superblock readers so we can start allowing some
blockdev mounts in user namespaces :)
3. check for privilege against the userns owning a superblock

-serge
