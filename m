From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v12
Date: Thu, 15 Sep 2011 13:27:57 +0400
Message-ID: <20110915092757.GA23404@albatros>
References: <20110913212447.918816776@openvz.org>
 <20110913235222.043927b3.akpm@linux-foundation.org>
 <20110914105607.GP25367@sun>
 <20110914111437.GA22516@atrey.karlin.mff.cuni.cz>
 <20110914113912.GQ25367@sun>
 <20110914134405.GV25367@sun>
 <20110914144841.GA7906@albatros>
 <20110914160018.GW25367@sun>
 <20110914160724.GA10612@albatros>
 <20110915091417.GA27755@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110915091417.GA27755@sun>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Pavel Machek <pavel@ucw.cz>, Andrew Morton <akpm00@gmail.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Kirill Shutemov <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, James Bottomley <jbottomley@parallels.com>, Nathan Lynch <ntl@pobox.com>, Zan Lynx <zlynx@acm.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

Hi,

On Thu, Sep 15, 2011 at 13:14 +0400, Cyrill Gorcunov wrote:
> On Wed, Sep 14, 2011 at 08:07:25PM +0400, Vasiliy Kulikov wrote:
> ...
> > 
> > No, I mean something else.  Assume you have a task, which does the
> > steps:
> > 
> > 1) opens some sensitive file as root.  This file is e.g. 0700.
> > 
> > 2) mmaps the file via opened fd, either RO or RW.
> > 
> > 3) closes fd.
> > 
> > 4) drops root.
> > 
> > Now it has a mapping of a privileged file, but cannot get fd of it
> > anyhow.  With map_files/ he may open his own /proc/$$/map_files/, pass
> > ptrace() check, and get fd of the privileged file.  He cannot explicitly
> > open it as it is 0700, but he may open it via map_files/ and get RO/RW
> > fd.
> > 
> 
> Hi Vasiliy, could you please check if the update below address all your
> concerns? Note that we still need at least RO access on such files.
> 
> 	Cyrill
> ---
> fs, proc: Introduce the /proc/<pid>/map_files/ directory v14
> 
> From: Pavel Emelyanov <xemul@parallels.com>
> 
> This one behaves similarly to the /proc/<pid>/fd/ one - it contains symlinks
> one for each mapping with file, the name of a symlink is "vma->vm_start-vma->vm_end",
> the target is the file. Opening a symlink results in a file that point exactly
> to the same inode as them vma's one.
> 
> For example the ls -l of some arbitrary /proc/<pid>/map_files/
> 
>  | lr-x------ 1 root root 64 Aug 26 06:40 7f8f80403000-7f8f80404000 -> /lib64/libc-2.5.so
>  | lr-x------ 1 root root 64 Aug 26 06:40 7f8f8061e000-7f8f80620000 -> /lib64/libselinux.so.1
>  | lr-x------ 1 root root 64 Aug 26 06:40 7f8f80826000-7f8f80827000 -> /lib64/libacl.so.1.1.0
>  | lr-x------ 1 root root 64 Aug 26 06:40 7f8f80a2f000-7f8f80a30000 -> /lib64/librt-2.5.so
>  | lr-x------ 1 root root 64 Aug 26 06:40 7f8f80a30000-7f8f80a4c000 -> /lib64/ld-2.5.so
> 
> This *helps* checkpointing process in three ways:
> 
> 1. When dumping a task mappings we do know exact file that is mapped by particular
>    region. We do this by opening /proc/$pid/map_files/address symlink the way we do
>    with file descriptors.

s/address/$address/ for consistency.

> 
> 2. This also helps in determining which anonymous shared mappings are shared with
>    each other by comparing the inodes of them.
> 
> 3. When restoring a set of process

s/process/processes/

> in case two of them has a mapping shared, we map
>    the memory by the 1st one and then open its /proc/$pid/map_files/address file and
>    map it by the 2nd task.

How can you restore a set of processes in case they share an RW mapping
as RW in both tasks if you deny opening /proc/$pid/map_files/$address as W?

> Using /proc/$pid/maps for this is quite inconvenient since it brings repeatable
> re-reading and reparsing for this text file which slows down restore procesure
> significantly. Also as being pointed in (3) it is a way easier to use top level
> shared mapping in children as /proc/$pid/map_files/address when needed.
[...]
> v14: (by Vasiliy Kulikov)
>  - for security reason the links are created with FMODE_READ mode
>    only even if the former file has FMODE_WRITE
>  - proc_map_files_lookup fails on any non-read-only queries.

Do you have a PoC of the dumper?  At least without the restorer.  If we
see an implementation of map_files/ user we probably identify what
operation it needs and what security restrictions we have to define.

Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
