From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
	directory v12
Date: Wed, 14 Sep 2011 13:14:38 +0200
Message-ID: <20110914111437.GA22516@atrey.karlin.mff.cuni.cz>
References: <20110913211359.674453213@openvz.org> <20110913212447.918816776@openvz.org> <20110913235222.043927b3.akpm@linux-foundation.org> <20110914105607.GP25367@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110914105607.GP25367@sun>
Sender: linux-kernel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm00@gmail.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Kirill Shutemov <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, James Bottomley <jbottomley@parallels.com>, Nathan Lynch <ntl@pobox.com>, Zan Lynx <zlynx@acm.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Vasiliy Kulikov <segoon@openwall.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

Hi!

> > 
> > > This one behaves similarly to the /proc/<pid>/fd/ one - it contains symlinks
> > > one for each mapping with file, the name of a symlink is "vma->vm_start-vma->vm_end",
> > > the target is the file. Opening a symlink results in a file that point exactly
> > > to the same inode as them vma's one.
> > 
> > We should fully work through Pavel Machek's comments, please.  For some
> > reason I'm a bit paranoid about security lately :(
> 
> Pavel, I somehow lost. What exactly the security issue here? There are a few
> patches from Vasiliy in -mm queue at moment. In particular one includes
> .permission set for fd/ handling. So I've updated the map_files as well
> (it's below). So please review and point me where the problem
> is. Thanks!

AFAICT, this recreates existing problem with /proc/<pid>/fd (see
discussion at 

http://www.securityfocus.com/archive/1/507386/30/0/threaded

). It creates object that looks like symlink, but does not behave as
one, and permissions of directories are not checked as they would be
if it was a symlink.

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
