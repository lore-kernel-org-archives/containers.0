From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v12
Date: Wed, 14 Sep 2011 15:39:12 +0400
Message-ID: <20110914113912.GQ25367@sun>
References: <20110913211359.674453213@openvz.org>
 <20110913212447.918816776@openvz.org>
 <20110913235222.043927b3.akpm@linux-foundation.org>
 <20110914105607.GP25367@sun>
 <20110914111437.GA22516@atrey.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110914111437.GA22516@atrey.karlin.mff.cuni.cz>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Andrew Morton <akpm00@gmail.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Kirill Shutemov <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, James Bottomley <jbottomley@parallels.com>, Nathan Lynch <ntl@pobox.com>, Zan Lynx <zlynx@acm.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Vasiliy Kulikov <segoon@openwall.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Wed, Sep 14, 2011 at 01:14:38PM +0200, Pavel Machek wrote:
> Hi!
> 
...
> > 
> > Pavel, I somehow lost. What exactly the security issue here? There are a few
> > patches from Vasiliy in -mm queue at moment. In particular one includes
> > .permission set for fd/ handling. So I've updated the map_files as well
> > (it's below). So please review and point me where the problem
> > is. Thanks!
> 
> AFAICT, this recreates existing problem with /proc/<pid>/fd (see
> discussion at 
> 
> http://www.securityfocus.com/archive/1/507386/30/0/threaded
> 
> ). It creates object that looks like symlink, but does not behave as
> one, and permissions of directories are not checked as they would be
> if it was a symlink.
> 
> 									Pavel

OK, so the problem is that we might return a path to the file mapped
even if the directory which consists the former file has its permission
changed, right? For example, lets say we have

| lr-x------ 1 cyrill cyrill 64 Sep 14 19:35 /proc/self/map_files/3d73a00000-3d73a1c000 -> /lib64/ld-2.5.so

and once /lib64 became unreadable we should not return the path to
3d73a00000-3d73a1c000 as well, that is what you mean, right?

	Cyrill
