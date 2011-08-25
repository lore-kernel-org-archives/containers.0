From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Thu, 25 Aug 2011 21:21:10 +0400
Message-ID: <20110825172109.GC6387@sun>
References: <20110824085329.GL29452@sun>
 <20110824111806.GA7191@albatros>
 <20110825082944.GH10030@sun>
 <20110825170147.GM2803@mtj.dyndns.org>
 <4E5680D2.1030608@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4E5680D2.1030608@parallels.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Tejun Heo <tj@kernel.org>, Vasiliy Kulikov <segoon@openwall.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Zan Lynx <zlynx@acm.org>, Andi Kleen <andi@firstfloor.org>
List-Id: containers.vger.kernel.org

On Thu, Aug 25, 2011 at 09:05:22PM +0400, Pavel Emelyanov wrote:
...
> > 
> > I would prefer if the filename included both start and end addresses
> > so that it matches the first column of /proc/PID/maps and ls'ing the
> > directory is more useful.  What do other people think?
> 
> Without 0x at the beginning this is not very convenient, but once we add them it no
> longer matches the contents of the /proc/pid/maps.
> 
> Just an opinion, do not mind adding <end> to the name.
> 

So Pavel, we can make the names to look as say "3d73a00000-3d73a01000"
leaving proc-inode structure unchanged, that's an idea, right?

	Cyrill
