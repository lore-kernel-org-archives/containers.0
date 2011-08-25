From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Thu, 25 Aug 2011 22:54:26 +0200
Message-ID: <20110825205426.GO2803@mtj.dyndns.org>
References: <20110824085329.GL29452@sun>
 <20110824111806.GA7191@albatros>
 <20110825082944.GH10030@sun>
 <20110825170147.GM2803@mtj.dyndns.org>
 <20110825170705.GA6387@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110825170705.GA6387@sun>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Vasiliy Kulikov <segoon@openwall.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, James Bottomley <jbottomley@parallels.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, containers@lists.osdl.org, Zan Lynx <zlynx@acm.org>, Andi Kleen <andi@firstfloor.org>
List-Id: containers.vger.kernel.org

Hello,

On Thu, Aug 25, 2011 at 09:07:05PM +0400, Cyrill Gorcunov wrote:
> This will force us to bloat proc_inode a bit more, since at moment we
> have a union such as
> 
> struct proc_inode {
> 	struct pid *pid;
> 	union {
> 		int fd;
> 		unsigned long vm_start;
> 	};
> 	...
> 
> also it will require to make a buffer for names twice bigger as well.
> If all this not a problem -- then sure we can do that ;)

I'm not too familiar with this area but I don't think bloating it a
bit would be such a big problem.  proc_inode is generated on the fly
as proc directories and files are accessed, so it's not like they'll
linearly hog down more memory with increasing number of entries (sysfs
had this sort of problem in the past).

Another thing is, I don't really see why we need vm_start, or fd for
that matter, in proc_inode at all.  proc_inode is created on the fly
only as dentry gets instantiated on demand, which means we always have
d_name on hand to tell what the file is supposed to point to.  In
fact, the code already uses name_to_int() to extract fd from d_name.
Hmmm... well yeah, it actually seems that proc_inode->fd is never used
and we can simply remove it.

So, we can do the same thing w/ these mapping files too.  We just need
name_to_map_range() or something.  Also, for most address ranges, the
name sould fit inside the inline name in dentry (32 bytes on 64bit),
so it really isn't gonna bloat anything.

Thanks.

-- 
tejun
