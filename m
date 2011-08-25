From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Thu, 25 Aug 2011 21:07:05 +0400
Message-ID: <20110825170705.GA6387@sun>
References: <20110824085329.GL29452@sun>
 <20110824111806.GA7191@albatros>
 <20110825082944.GH10030@sun>
 <20110825170147.GM2803@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110825170147.GM2803@mtj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Vasiliy Kulikov <segoon@openwall.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, James Bottomley <jbottomley@parallels.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, containers@lists.osdl.org, Zan Lynx <zlynx@acm.org>, Andi Kleen <andi@firstfloor.org>
List-Id: containers.vger.kernel.org

On Thu, Aug 25, 2011 at 07:01:47PM +0200, Tejun Heo wrote:
> Hello,
> 
> On Thu, Aug 25, 2011 at 12:29:44PM +0400, Cyrill Gorcunov wrote:
> >  | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73a00000 -> /lib64/ld-2.5.so
> >  | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73c1b000 -> /lib64/ld-2.5.so
> >  | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73c1c000 -> /lib64/ld-2.5.so
> >  | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73e00000 -> /lib64/libc-2.5.so
> >  | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73f4e000 -> /lib64/libc-2.5.so
> 
> I would prefer if the filename included both start and end addresses
> so that it matches the first column of /proc/PID/maps and ls'ing the
> directory is more useful.  What do other people think?
> 

This will force us to bloat proc_inode a bit more, since at moment we
have a union such as

struct proc_inode {
	struct pid *pid;
	union {
		int fd;
		unsigned long vm_start;
	};
	...

also it will require to make a buffer for names twice bigger as well.
If all this not a problem -- then sure we can do that ;)

	Cyrill
