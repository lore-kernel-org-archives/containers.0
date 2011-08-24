From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Wed, 24 Aug 2011 19:22:22 +0400
Message-ID: <20110824152222.GZ29452@sun>
References: <20110824085329.GL29452@sun>
 <4E551331.1010709@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4E551331.1010709@acm.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Zan Lynx <zlynx@acm.org>
Cc: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Serge Hallyn <serge.hallyn@canonical.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>
List-Id: containers.vger.kernel.org

On Wed, Aug 24, 2011 at 09:05:21AM -0600, Zan Lynx wrote:
> On 8/24/2011 2:53 AM, Cyrill Gorcunov wrote:
> > From: Pavel Emelyanov <xemul@parallels.com>
> > 
> > This one behaves similarly to the /proc/<pid>/fd/ one - it contains symlinks
> > one for each mapping with file, the name of a symlink is vma->vm_start, the
> > target is the file. Opening a symlink results in a file that point exactly
> > to the same inode as them vma's one.
> > 
> > This thing is aimed to help checkpointing processes.
> > 
> > For example the ls -l of some arbitrary /proc/<pid>/map_files/
> > 
> >  | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73a00000 -> /lib64/ld-2.5.so
> [snip]
> 
> Just curious: How do these symlinks work when the process reading a
> /proc file is in a chroot or a different namespace?
> 
> For example, a chroot environment might have independent copies of
> /lib64/ld-2.5.so and a bind mount of /proc. Does the symlink then point
> to the wrong file?

To be fair, I personally didn't tried such scenario but it should be
the same behaviour as for /proc/$pid/fd since data is taken from
a task pointed by pid. I'll check though, good question.

	Cyrill
