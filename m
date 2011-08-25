From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Thu, 25 Aug 2011 21:39:53 +0400
Message-ID: <20110825173953.GE6387@sun>
References: <20110824085329.GL29452@sun>
 <20110824111806.GA7191@albatros>
 <20110825082944.GH10030@sun>
 <20110825173642.GA3288@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110825173642.GA3288@albatros>
Sender: linux-kernel-owner@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, James Bottomley <jbottomley@parallels.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, containers@lists.osdl.org, Zan Lynx <zlynx@acm.org>, Andi Kleen <andi@firstfloor.org>
List-Id: containers.vger.kernel.org

On Thu, Aug 25, 2011 at 09:36:42PM +0400, Vasiliy Kulikov wrote:
...
> > +
> > +	result = ERR_PTR(-EPERM);
> > +	if (!ptrace_may_access(task, PTRACE_MODE_READ));
> > +		goto out_no_mm;
> 
> Probably
> 
>     result = ERR_PTR(-ENOENT);
> 
> belongs here?
> 

Don't think so, it should point that permission failed
rather no such entry. Or this might break some tools?

	Cyrill
