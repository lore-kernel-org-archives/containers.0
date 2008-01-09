From: Nigel Cunningham <nigel-MhVfhJ0qHmuWn91e4EydUaxOck334EZe@public.gmane.org>
Subject: Re: [patch 7/9] unprivileged mounts: allow unprivileged fuse mounts
Date: Wed, 09 Jan 2008 20:29:24 +1100
Message-ID: <478493F4.2040602@nigel.suspend2.net>
References: <20080108113502.184459371@szeredi.hu> <20080108113630.861045063@szeredi.hu> <20080108214625.GE5050@ucw.cz> <E1JCN9I-0004DB-DF@pomaz-ex.szeredi.hu> <47840DAC.5000108@nigel.suspend2.net> <E1JCWax-0005Ck-Kg@pomaz-ex.szeredi.hu>
Reply-To: nigel-MhVfhJ0qHmuWn91e4EydUaxOck334EZe@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <E1JCWax-0005Ck-Kg-8f8m9JG5TPIdUIPVzhDTVZP2KDSNp7ea@public.gmane.org>
Sender: util-linux-ng-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: pavel-+ZI9xUNit7I@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, util-linux-ng-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi.

Miklos Szeredi wrote:
>>>> On Tue 2008-01-08 12:35:09, Miklos Szeredi wrote:
>>>>> From: Miklos Szeredi <mszeredi-AlSwsSmVLrQ@public.gmane.org>
>>>>>
>>>>> Use FS_SAFE for "fuse" fs type, but not for "fuseblk".
>>>>>
>>>>> FUSE was designed from the beginning to be safe for unprivileged users.  This
>>>>> has also been verified in practice over many years.  In addition unprivileged
>>>> Eh? So 'kill -9 no longer works' and 'suspend no longer works' is not
>>>> considered important enough to even mention?
>>> No.  Because in practice they don't seem to matter.  Also because
>>> there's no way in which fuse could be done differently to address
>>> these issues.
>> Could you clarify, please? I hope I'm getting the wrong end of the stick
>> - it sounds to me like you and Pavel are saying that this patch breaks
>> suspending to ram (and hibernating?) but you want to push it anyway
>> because you haven't been able to produce an instance, don't think
>> suspending or hibernating matter and couldn't fix fuse anyway?
> 
> This patch has nothing to do with suspend or hibernate.  What this
> patchset does, is help get rid of fusermount, a suid-root mount
> helper.  It also opens up new possibilities, which are not fuse
> related.

That's what I thought. So what was Pavel talking about with "kill -9 no
longer works" and "suspend no longer works" above? I couldn't understand
it from the context.

> Fuse has bad interactions with the freezer, theoretically.  In
> practice, I remember just one bug report (that sparked off this whole
> "do we need freezer, or don't we" flamefest), that actually got fixed
> fairly quickly, ...maybe.  Rafael probably remembers better.

I think they just gave up and considered it unsolvable. I'm not sure it is.

>>> The 'kill -9' thing is basically due to VFS level locking not being
>>> interruptible.  It could be changed, but I'm not sure it's worth it.
>>>
>>> For the suspend issue, there are also no easy solutions.
>> What are the non-easy solutions?
> 
> The ability to freeze tasks in uninterruptible sleep, or more
> generally at any preempt point (except when drivers are poking
> hardware).

Couldn't some sort of scheduler based solution deal with the
uninterruptible sleeping case?

> I know this doesn't play well with userspace hibernate, and I don't
> think it can be resolved without going the kexec way.

I can see the desirability of kexec when it comes to avoiding the
freezer, but comes with its own problems too - having the original
context usable is handy, not having to set aside a large amount of space
for a second kernel is also desirable and there are still greater issues
of transferring information backwards and forwards between the two kernels.

Regards,

Nigel
