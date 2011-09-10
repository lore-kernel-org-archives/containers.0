From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [kernel-hardening] Re: [patch 2/2] fs, proc: Introduce the
 /proc/<pid>/map_files/ directory v6
Date: Sat, 10 Sep 2011 17:49:05 +0400
Message-ID: <20110910134904.GD14420@sun>
References: <20110906173341.GM18425@mtj.dyndns.org>
 <20110907112301.GA12157@albatros>
 <20110907215329.GB28162@sun>
 <20110907151323.613e62e7.akpm@linux-foundation.org>
 <20110907224234.GD28162@sun>
 <20110907155332.beda7d3d.akpm@linux-foundation.org>
 <20110908054826.GF28162@sun>
 <20110908055025.GG28162@sun>
 <20110908060405.GH28162@sun>
 <20110910132101.GA14535@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110910132101.GA14535@albatros>
Sender: linux-kernel-owner@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: kernel-hardening@lists.openwall.com, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On Sat, Sep 10, 2011 at 05:21:01PM +0400, Vasiliy Kulikov wrote:
...
> > +
> > +	if (!ptrace_may_access(task, PTRACE_MODE_READ))
> 
>         put_task_struct(task) belongs here.
> 

Yeah, thanks! I'll update.

	Cyrill
