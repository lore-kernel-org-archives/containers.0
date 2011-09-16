From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v12
Date: Fri, 16 Sep 2011 22:40:49 +0400
Message-ID: <20110916184049.GD8599@sun>
References: <20110915091417.GA27755@sun>
 <20110915092757.GA23404@albatros>
 <20110915102922.GB27755@sun>
 <20110915105651.GA17575@albatros>
 <20110915201939.GE12040@sun>
 <20110916175618.GA20046@albatros>
 <20110916180731.GB8599@sun>
 <20110916181146.GA20801@albatros>
 <20110916182654.GC8599@sun>
 <20110916183150.GA26226@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110916183150.GA26226@shutemov.name>
Sender: linux-kernel-owner@vger.kernel.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Vasiliy Kulikov <segoon@openwall.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Machek <pavel@ucw.cz>, Andrew Morton <akpm00@gmail.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, James Bottomley <jbottomley@parallels.com>, Nathan Lynch <ntl@pobox.com>, Zan Lynx <zlynx@acm.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>
List-Id: containers.vger.kernel.org

On Fri, Sep 16, 2011 at 09:31:50PM +0300, Kirill A. Shutemov wrote:
...
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> > Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> > Reviewed-by: Vasiliy Kulikov <segoon@openwall.com>
> > CC: Tejun Heo <tj@kernel.org>
> > CC: Vasiliy Kulikov <segoon@openwall.com>
> > CC: "Kirill A. Shutemov" <kirill@shutemov.name>
> > CC: Alexey Dobriyan <adobriyan@gmail.com>
> > CC: Al Viro <viro@ZenIV.linux.org.uk>
> > CC: Andrew Morton <akpm@linux-foundation.org>
> > CC: Pavel Machek <pavel@ucw.cz>
> 
> My Reviewed-by is in force.
> 

Thanks, Kirill! (I didn't put it in first place since we tuned
code a bit and I didn't know your opinion on new changes)
