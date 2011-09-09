From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Thu, 8 Sep 2011 23:00:20 -0700
Message-ID: <20110908230020.11f306be.akpm@linux-foundation.org>
References: <20110906173341.GM18425@mtj.dyndns.org>
	<20110907112301.GA12157@albatros>
	<20110907215329.GB28162@sun>
	<20110907151323.613e62e7.akpm@linux-foundation.org>
	<20110907224234.GD28162@sun>
	<20110907155332.beda7d3d.akpm@linux-foundation.org>
	<20110908054826.GF28162@sun>
	<20110908055025.GG28162@sun>
	<20110908060405.GH28162@sun>
	<20110908165201.59e82c71.akpm@linux-foundation.org>
	<20110909054819.GN28162@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110909054819.GN28162@sun>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Vasiliy Kulikov <segoon@openwall.com>, Tejun Heo <tj@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, kernel-hardening@lists.openwall.com, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On Fri, 9 Sep 2011 09:48:19 +0400 Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> > 
> > <looks at the warning>
> > 
> > fs/proc/base.c: In function 'proc_map_files_instantiate':
> > fs/proc/base.c:2348: warning: assignment from incompatible pointer type
> > 
> > err, that code will crash at runtime and it isn't trivial to fix. 
> > How could this happen?
> > 
> 
> Hmm. I never saw this warning. (Andrew, I'm still unable to fetch
> your current -mm tree, is there some place other than kernel.org?

Nope, sorry - we're dead in the water at present.

> So the patch is done on top of 3.1-rc3). I guess this warrning is
> from p = flex_array_get(fa, i); ? (since I don't have any warning
> at all).

The warning is from

	ei->op.proc_get_link = proc_map_files_get_link;

The lhs has type

union proc_op {
	int (*proc_get_link)(struct inode *, struct path *);

and the rhs has type

static int proc_map_files_get_link(struct dentry *dentry, struct path *path)

So we end up passing an inode* to a function which expects a dentry*.

That's in 3.1-rc4.  proc_op.proc_get_link() hasn't changed since 3.0 (at least).
