From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [patch 9/9] unprivileged mounts: add "no submounts" flag
Date: Wed, 16 Jan 2008 10:43:10 +0100
Message-ID: <E1JF4ne-0003HO-CG@pomaz-ex.szeredi.hu>
References: <20080108113502.184459371@szeredi.hu> <20080108113634.382855604@szeredi.hu> <20080114233910.GI6704@sergelap.austin.ibm.com> <E1JEjEE-0000xZ-RU@pomaz-ex.szeredi.hu> <643ea2b10801150253i735d7342q73bf01f864d6167c@mail.gmail.com> <E1JEjUx-00010q-Ny@pomaz-ex.szeredi.hu> <20080115134719.GB4453@sergelap.austin.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-reply-to: <20080115134719.GB4453@sergelap.austin.ibm.com>
	(serue@us.ibm.com)
Sender: linux-fsdevel-owner@vger.kernel.org
Cc: miklos@szeredi.hu, accensi@gmail.com, serue@us.ibm.com, akpm@linux-foundation.org, hch@infradead.org, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org
List-Id: containers.vger.kernel.org

> > > Why not "nosubmnt"?
> > 
> > Why not indeed.  Maybe I should try to use my brain sometime.
> 
> Well it really should have 'user' or 'unpriv' in the name
> somewhere.  'nosubmnt' is more confusing than 'nomnt' because
> it no submounts really sounds like a reasonable thing in
> itself...

I slept on it, and I still think 'nosubmnt' might be the best
compromise.  Obviously the superuser has privileges, that override
what is normally allowed, and we don't find it strange when a
read-only file is happily being written by root.

It may feel wrong in the context of mounts, because we are so used to
mounts being privileged-only.

Objections?  Once this goes in, it will stay the same forever, so now
is the time to express any doubts...

Thanks,
Miklos
