From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [patch 07/10] unprivileged mounts: add sysctl tunable for
	"safe" property
Date: Tue, 22 Jan 2008 14:48:28 -0600
Message-ID: <20080122204828.GA1212@sergelap.austin.ibm.com>
References: <20080116123147.466284860@szeredi.hu> <20080116123433.126167584@szeredi.hu> <20080121203249.GB5536@sergelap.austin.rr.com> <E1JH4Kz-0006gt-MC@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E1JH4Kz-0006gt-MC@pomaz-ex.szeredi.hu>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: serue@us.ibm.com, akpm@linux-foundation.org, hch@infradead.org, viro@ftp.linux.org.uk, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Miklos Szeredi (miklos@szeredi.hu):
> > What do you think about doing this only if FS_SAFE is also set,
> > so for instance at first only FUSE would allow itself to be
> > made user-mountable?
> > 
> > A safe thing to do, or overly intrusive?
> 
> It goes somewhat against the "no policy in kernel" policy ;).  I think
> the warning in the documentation should be enough to make sysadmins
> think twice before doing anything foolish:

Warning in which documentation?  A sysadmin considering setting fs_safe
for ext2 or xfs isn't going to be looking at fuse docs, which I think is
what you're talking about.  Are you going to add a file under
Documentation/filesystems?

> > +Care should be taken when enabling this, since most
> > +filesystems haven't been designed with unprivileged mounting
> > +in mind.
> > +
> 
> BTW, filesystems like 'proc' and 'sysfs' should also be safe, although
> the only use for them being marked safe is if the users are allowed to
> umount them from their private namespace (otherwise a 'mount --bind'
> has the same effect as a new mount).
> 
> Thanks,
> Miklos
