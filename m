From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Wed, 7 Sep 2011 01:51:44 +0900
Message-ID: <20110906165144.GJ18425@mtj.dyndns.org>
References: <20110831140416.GA17626@shutemov.name>
 <20110831142622.GB30615@sun>
 <20110831151023.5b7e12da.akpm@linux-foundation.org>
 <20110901080508.GF30615@sun>
 <20110902163711.GA3124@albatros>
 <20110905185358.GA2103@albatros>
 <20110905192009.GJ761@sun>
 <20110905194908.GA2690@albatros>
 <20110905203627.GL761@sun>
 <20110906101518.GA4799@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110906101518.GA4799@albatros>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, kernel-hardening@lists.openwall.com, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

Hello, Vasiliy.

On Tue, Sep 06, 2011 at 02:15:18PM +0400, Vasiliy Kulikov wrote:
>   c) If dentry is lazily dropped on each access attempt (or each illegal
>      access) then PID2 can:
> 
>      i) read dentry line of /proc/slabinfo
>      ii) call link(2) against /proc/PID/fd, which invalidates the
>          specific dentry
>      iii) re-read dentry line of /proc/slabinfo.  If it has decreased by
>          one, the dentry existed before (ii).

If we really worry about this, probably the right thing to do is
hiding slabinfo from mortal UIDs instead of worrying about what
exactly are freed or not from each user.

Thanks.

-- 
tejun
