From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/ directory
 v12
Date: Wed, 14 Sep 2011 20:13:17 +0400
Message-ID: <4E70D29D.20104@parallels.com>
References: <20110913211359.674453213@openvz.org> <20110913212447.918816776@openvz.org> <20110913235222.043927b3.akpm@linux-foundation.org> <20110914105607.GP25367@sun> <20110914111437.GA22516@atrey.karlin.mff.cuni.cz> <20110914113912.GQ25367@sun> <20110914134405.GV25367@sun> <20110914144841.GA7906@albatros> <20110914160018.GW25367@sun> <20110914160724.GA10612@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110914160724.GA10612@albatros>
Sender: linux-kernel-owner@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Machek <pavel@ucw.cz>, Andrew Morton <akpm00@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Kirill Shutemov <kirill@shutemov.name>, James Bottomley <jbottomley@parallels.com>, Nathan Lynch <ntl@pobox.com>, Zan Lynx <zlynx@acm.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

> No, I mean something else.  Assume you have a task, which does the
> steps:
> 
> 1) opens some sensitive file as root.  This file is e.g. 0700.
> 
> 2) mmaps the file via opened fd, either RO or RW.
> 
> 3) closes fd.
> 
> 4) drops root.
> 
> Now it has a mapping of a privileged file, but cannot get fd of it
> anyhow.  With map_files/ he may open his own /proc/$$/map_files/, pass
> ptrace() check, and get fd of the privileged file.  He cannot explicitly
> open it as it is 0700, but he may open it via map_files/ and get RO/RW
> fd.
> 

What is the problem here - the fact that we have some file considered to
be private be open-able by somebody else, or the fact that we can truncate
the file being mapped?

If the fist issue stands, then it also stands for /proc/pid/fd and thus we
don't introduce the new problem.

If the second, then it's not a problem as mm can handle this already.

Thanks,
Pavel
