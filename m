From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [patch 8/9] unprivileged mounts: propagation: inherit owner
	from parent
Date: Tue, 15 Jan 2008 11:39:08 +0100
Message-ID: <E1JEjCG-0000wz-BS@pomaz-ex.szeredi.hu>
References: <20080108113502.184459371@szeredi.hu> <20080108113632.895453887@szeredi.hu> <20080114231340.GG6704@sergelap.austin.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-reply-to: <20080114231340.GG6704@sergelap.austin.ibm.com>
	(serue@us.ibm.com)
Sender: linux-fsdevel-owner@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org
List-Id: containers.vger.kernel.org

> Quoting Miklos Szeredi (miklos@szeredi.hu):
> > From: Miklos Szeredi <mszeredi@suse.cz>
> > 
> > On mount propagation, let the owner of the clone be inherited from the
> > parent into which it has been propagated.  Also if the parent has the
> > "nosuid" flag, set this flag for the child as well.
> 
> What about nodev?

Hmm, I think the nosuid thing is meant to prevent suid mounts being
introduced into a "suidless" namespace.  This doesn't apply to dev
mounts, which are quite safe in a suidless environment, as long as the
user is not able to create devices.  But that should be taken care of
by capability tests.

I'll update the description.

Thanks,
Miklos
