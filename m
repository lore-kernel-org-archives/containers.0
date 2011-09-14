From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v12
Date: Wed, 14 Sep 2011 18:57:46 +0400
Message-ID: <20110914145746.GA9074@albatros>
References: <20110913211359.674453213@openvz.org>
 <20110913212447.918816776@openvz.org>
 <20110913235222.043927b3.akpm@linux-foundation.org>
 <20110914105607.GP25367@sun>
 <20110914111437.GA22516@atrey.karlin.mff.cuni.cz>
 <20110914113912.GQ25367@sun>
 <20110914134405.GV25367@sun>
 <20110914144841.GA7906@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110914144841.GA7906@albatros>
Sender: linux-kernel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Pavel Machek <pavel@ucw.cz>, Andrew Morton <akpm00@gmail.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Kirill Shutemov <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, James Bottomley <jbottomley@parallels.com>, Nathan Lynch <ntl@pobox.com>, Zan Lynx <zlynx@acm.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Wed, Sep 14, 2011 at 18:48 +0400, Vasiliy Kulikov wrote:
> > So, there is no *new* hole.
> 
> Actually now I see the difference between having something mapped and
> having an _fd_ of this something.
> 
> Relevant code:
> 
> +static struct dentry *
> +proc_map_files_instantiate(struct inode *dir, struct dentry *dentry,
> +              struct task_struct *task, const void *ptr)
> +{
> ...
> +   inode->i_mode = S_IFLNK;
> +
> +   if (file->f_mode & FMODE_READ)
> +       inode->i_mode |= S_IRUSR | S_IXUSR;
> +   if (file->f_mode & FMODE_WRITE)
> +       inode->i_mode |= S_IWUSR | S_IXUSR;
> 
> 
> If you have a write mmap area, but no fd, you may not trunc a file; with
> map_files/ you may get an fd and ftrunc it.

Also it unconditionally adds +x, but I don't think it breaks any
security assumption as (1) there is no +s and (2) fd is not a directory.

Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
