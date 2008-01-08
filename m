From: Nigel Cunningham <nigel@nigel.suspend2.net>
Subject: Re: [patch 7/9] unprivileged mounts: allow unprivileged fuse mounts
Date: Wed, 09 Jan 2008 10:56:28 +1100
Message-ID: <47840DAC.5000108@nigel.suspend2.net>
References: <20080108113502.184459371@szeredi.hu> <20080108113630.861045063@szeredi.hu> <20080108214625.GE5050@ucw.cz> <E1JCN9I-0004DB-DF@pomaz-ex.szeredi.hu>
Reply-To: nigel@nigel.suspend2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <E1JCN9I-0004DB-DF@pomaz-ex.szeredi.hu>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: pavel@ucw.cz, akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org
List-Id: containers.vger.kernel.org

Hi.

Miklos Szeredi wrote:
>> On Tue 2008-01-08 12:35:09, Miklos Szeredi wrote:
>>> From: Miklos Szeredi <mszeredi@suse.cz>
>>>
>>> Use FS_SAFE for "fuse" fs type, but not for "fuseblk".
>>>
>>> FUSE was designed from the beginning to be safe for unprivileged users.  This
>>> has also been verified in practice over many years.  In addition unprivileged
>> Eh? So 'kill -9 no longer works' and 'suspend no longer works' is not
>> considered important enough to even mention?
> 
> No.  Because in practice they don't seem to matter.  Also because
> there's no way in which fuse could be done differently to address
> these issues.

Could you clarify, please? I hope I'm getting the wrong end of the stick
- it sounds to me like you and Pavel are saying that this patch breaks
suspending to ram (and hibernating?) but you want to push it anyway
because you haven't been able to produce an instance, don't think
suspending or hibernating matter and couldn't fix fuse anyway?

> The 'kill -9' thing is basically due to VFS level locking not being
> interruptible.  It could be changed, but I'm not sure it's worth it.
> 
> For the suspend issue, there are also no easy solutions.

What are the non-easy solutions?

Regards,

Nigel
