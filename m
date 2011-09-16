From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v12
Date: Fri, 16 Sep 2011 22:07:32 +0400
Message-ID: <20110916180731.GB8599@sun>
References: <20110914134405.GV25367@sun>
 <20110914144841.GA7906@albatros>
 <20110914160018.GW25367@sun>
 <20110914160724.GA10612@albatros>
 <20110915091417.GA27755@sun>
 <20110915092757.GA23404@albatros>
 <20110915102922.GB27755@sun>
 <20110915105651.GA17575@albatros>
 <20110915201939.GE12040@sun>
 <20110916175618.GA20046@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110916175618.GA20046@albatros>
Sender: linux-kernel-owner@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: Pavel Machek <pavel@ucw.cz>, Andrew Morton <akpm00@gmail.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Kirill Shutemov <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, James Bottomley <jbottomley@parallels.com>, Nathan Lynch <ntl@pobox.com>, Zan Lynx <zlynx@acm.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Fri, Sep 16, 2011 at 09:56:18PM +0400, Vasiliy Kulikov wrote:
...
> > 
> > v14: (by Vasiliy Kulikov)
> >  - for security reason map_files/ entries are allowed for
> >    readers with CAP_SYS_ADMIN credentials granted only
> 
> This changelog is currently much longer than the commit description text ;)

Yes, I know ;) I would like to keep it (to appreciate everyone who spent time
in review and feedback).
...
> 
> > +
> > + inode = dentry->d_inode;
> > + task = get_proc_task(inode);
> > + if (!task)
> > +         goto out_notask;
> > +
> > + if (!ptrace_may_access(task, PTRACE_MODE_READ))
> > +         goto out;
> 
> While this is not needed with capable() check, it's OK to keep it for
> the future more finegranted access checks.

yeah

> 
> BTW, not a big deal, but probably you should return -EACCES on
> !capable() as file presence is not an issue in this case.
> 
>     if (!ptrace_may_access(task, PTRACE_MODE_READ))
>         goto out_notask;
> 
>     status = -EACCES;
>     if (!capable(CAP_SYS_ADMIN))
>         goto out_notask;
> 
>     status = 0;
> 
> 

That's not a proble to fix it actually. So can I fix it and
put some tage here (Reviewed or something?).

	Cyrill
