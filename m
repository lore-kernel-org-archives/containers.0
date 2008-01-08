From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [patch 7/9] unprivileged mounts: allow unprivileged fuse mounts
Date: Tue, 8 Jan 2008 23:58:20 +0100
Message-ID: <20080108225820.GA9735@elf.ucw.cz>
References: <20080108113502.184459371@szeredi.hu> <20080108113630.861045063@szeredi.hu> <20080108214625.GE5050@ucw.cz> <E1JCN9I-0004DB-DF@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E1JCN9I-0004DB-DF@pomaz-ex.szeredi.hu>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org
List-Id: containers.vger.kernel.org

On Tue 2008-01-08 23:42:20, Miklos Szeredi wrote:
> > On Tue 2008-01-08 12:35:09, Miklos Szeredi wrote:
> > > From: Miklos Szeredi <mszeredi@suse.cz>
> > > 
> > > Use FS_SAFE for "fuse" fs type, but not for "fuseblk".
> > > 
> > > FUSE was designed from the beginning to be safe for unprivileged users.  This
> > > has also been verified in practice over many years.  In addition unprivileged
> > 
> > Eh? So 'kill -9 no longer works' and 'suspend no longer works' is not
> > considered important enough to even mention?
> 
> No.  Because in practice they don't seem to matter.  Also because
> there's no way in which fuse could be done differently to address
> these issues.
> 
> The 'kill -9' thing is basically due to VFS level locking not being
> interruptible.  It could be changed, but I'm not sure it's worth it.

Well, I believe it should be changed. "You need to mount /sys, then
echo X to Y before kill -9 works" does not look nice... I agree it is
not easy.

> > 'updatedb no longer works' is not a problem?
> 
> I haven't seen any problems with updatedb, and haven't had any bug
> reports about it either.

Ok, I don't know much about FUSE. In current version, if user creates
infinite maze and mounts it under ~, updatedb just does not enter it?

> AFAIR there were two security vulnerabilities in fuse's history, one
> of them an information leak in the kernel module, and the other one an
> mtab corruption issue in the fusermount utility.  I don't think this
> is such a bad track record.

Not bad indeed. But I'd consider 'kill -9 not working' to be DoS
vulnerability... and I'm woried about problems fuse + user mounts
expose in other parts of system.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
