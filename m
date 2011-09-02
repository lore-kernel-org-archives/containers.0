From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Thu, 1 Sep 2011 17:09:58 -0700
Message-ID: <20110902000958.GE1919@count0.beaverton.ibm.com>
References: <20110831075814.003575573@openvz.org>
 <20110831080229.100652529@openvz.org>
 <20110831090612.GA3253@albatros>
 <20110831112642.GI25465@sun>
 <20110831140416.GA17626@shutemov.name>
 <20110831142622.GB30615@sun>
 <20110831151023.5b7e12da.akpm@linux-foundation.org>
 <4E5F3B25.9030701@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4E5F3B25.9030701@parallels.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vasiliy Kulikov <segoon@openwall.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Serge Hallyn <serge@hallyn.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>
List-Id: containers.vger.kernel.org

On Thu, Sep 01, 2011 at 11:58:29AM +0400, Pavel Emelyanov wrote:
> > What additional kernel patches are required to bring that effort to a
> > usable state and where are those patches?
> 
> * The one you've already accepted with ->statfs for pipefs.
> * PTRACE_SEIZE set from Tejun (RFC was sent some time earlier)
> * CLONE_USEPID flag for the clone() syscall (Cyrill will re-send a bit later)

Is that the last CLONE_ flag? Does it fully support nesting of pid namespaces?

What happened to the idea of using the existing eclone patches instead?

Cheers,
	-Matt Helsley
