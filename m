From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v12
Date: Wed, 14 Sep 2011 20:21:43 +0400
Message-ID: <20110914162143.GA11157@albatros>
References: <20110913212447.918816776@openvz.org>
 <20110913235222.043927b3.akpm@linux-foundation.org>
 <20110914105607.GP25367@sun>
 <20110914111437.GA22516@atrey.karlin.mff.cuni.cz>
 <20110914113912.GQ25367@sun>
 <20110914134405.GV25367@sun>
 <20110914144841.GA7906@albatros>
 <20110914160018.GW25367@sun>
 <20110914160724.GA10612@albatros>
 <4E70D29D.20104@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4E70D29D.20104@parallels.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Machek <pavel@ucw.cz>, Andrew Morton <akpm00@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Kirill Shutemov <kirill@shutemov.name>, James Bottomley <jbottomley@parallels.com>, Nathan Lynch <ntl@pobox.com>, Zan Lynx <zlynx@acm.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Wed, Sep 14, 2011 at 20:13 +0400, Pavel Emelyanov wrote:
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
> What is the problem here - the fact that we have some file considered to
> be private be open-able by somebody else, or the fact that we can truncate
> the file being mapped?

The latter - the file, which is considered to be restricted to a process
as W only without ability to truncate it, now can be truncated.  The
process after (4) had no such ability without map_files/ with current
permission model of mmap'ed files.  Or I am missing something?

FWIW, ftruncate() might be not the only syscall which makes sense to use
in this case, I just thought about it.

Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
