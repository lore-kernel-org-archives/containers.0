From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v12
Date: Wed, 14 Sep 2011 18:48:41 +0400
Message-ID: <20110914144841.GA7906@albatros>
References: <20110913211359.674453213@openvz.org>
 <20110913212447.918816776@openvz.org>
 <20110913235222.043927b3.akpm@linux-foundation.org>
 <20110914105607.GP25367@sun>
 <20110914111437.GA22516@atrey.karlin.mff.cuni.cz>
 <20110914113912.GQ25367@sun>
 <20110914134405.GV25367@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110914134405.GV25367@sun>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Pavel Machek <pavel@ucw.cz>, Andrew Morton <akpm00@gmail.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Kirill Shutemov <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, James Bottomley <jbottomley@parallels.com>, Nathan Lynch <ntl@pobox.com>, Zan Lynx <zlynx@acm.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

Hi,

On Wed, Sep 14, 2011 at 17:44 +0400, Cyrill Gorcunov wrote:
> On Wed, Sep 14, 2011 at 03:39:12PM +0400, Cyrill Gorcunov wrote:
> ...
> > > 
> > > AFAICT, this recreates existing problem with /proc/<pid>/fd (see
> > > discussion at 
> > > 
> > > http://www.securityfocus.com/archive/1/507386/30/0/threaded
> > > 
> > > ). It creates object that looks like symlink, but does not behave as
> > > one, and permissions of directories are not checked as they would be
> > > if it was a symlink.

The only difference between fd/X and dup(X) was the ability to write to
an fd opened as RO.  Now it is fixed:

$ ls -l 123
-rw-r--r-- 1 vasya vasya 0 Sep 14 18:21 123
$ id
uid=1008(new1) gid=1008(new1) groups=1008(new1)
$ bash 4< /tmp/123
new1@albatros:/tmp$ echo bla >&4
bash: 4: Bad file descriptor
new1@albatros:/tmp$ echo bla >/proc/$$/fd/4
bash: /proc/8527/fd/4: Permission denied

I don't really see any difference between opening fd/* and dup'ing file
descriptors with the current code.


> So, there is no *new* hole.

Actually now I see the difference between having something mapped and
having an _fd_ of this something.

Relevant code:

+static struct dentry *
+proc_map_files_instantiate(struct inode *dir, struct dentry *dentry,
+              struct task_struct *task, const void *ptr)
+{
...
+   inode->i_mode = S_IFLNK;
+
+   if (file->f_mode & FMODE_READ)
+       inode->i_mode |= S_IRUSR | S_IXUSR;
+   if (file->f_mode & FMODE_WRITE)
+       inode->i_mode |= S_IWUSR | S_IXUSR;


If you have a write mmap area, but no fd, you may not trunc a file; with
map_files/ you may get an fd and ftrunc it.


> Both fd/ and map_files/ have ptrace_may_access checks, which
> (as you pointed) might be not enough, but squashing all changes
> into one big path seems to be not that good idea.

ptrace() check is irrelevant to the access bypasses by the task owner.

> Vasiliy, as far as I remember you had something in mind on
> fd/ additional fixups, no?

Only closing fd presense leak:

http://www.openwall.com/lists/kernel-hardening/2011/09/10/3
http://www.openwall.com/lists/kernel-hardening/2011/09/10/4

Unfortunatelly, not yet applied/commented :(

Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
