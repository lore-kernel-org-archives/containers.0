From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [patch 4/9] unprivileged mounts: propagate error values from
	clone_mnt
Date: Tue, 15 Jan 2008 11:15:55 +0100
Message-ID: <E1JEipn-0000tq-3Q@pomaz-ex.szeredi.hu>
References: <20080108113502.184459371@szeredi.hu> <20080108113624.898035951@szeredi.hu> <20080114222305.GD6704@sergelap.austin.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-reply-to: <20080114222305.GD6704@sergelap.austin.ibm.com>
	(serue@us.ibm.com)
Sender: linux-fsdevel-owner@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org
List-Id: containers.vger.kernel.org

> Quoting Miklos Szeredi (miklos@szeredi.hu):
> > From: Miklos Szeredi <mszeredi@suse.cz>
> > 
> > Allow clone_mnt() to return errors other than ENOMEM.  This will be used for
> > returning a different error value when the number of user mounts goes over the
> > limit.
> > 
> > Fix copy_tree() to return EPERM for unbindable mounts.
> > 
> > Don't propagate further from dup_mnt_ns() as that copy_tree() can only fail
> > with -ENOMEM.
> 
> I see what you're saying, but it just seems like it's bound to be more
> confusing this way.

Ah yes, this is indeed confusing.  Last time dup_mnt_ns() returned a
namespace pointer or NULL.  But now I see it returns an ERR_PTR(error)
instead, which means it's cleaner to just propagate the error value.
I'll fix this.

Thanks,
Miklos
