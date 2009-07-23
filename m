From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/4] Support named cgroups hierarchies
Date: Thu, 23 Jul 2009 14:50:20 +0800
Message-ID: <4A68082C.8010604__34593.347766395$1248331948$gmane$org@cn.fujitsu.com>
References: <20090722194644.7481.47805.stgit@menage.mtv.corp.google.com>	
	<20090722195029.7481.94700.stgit@menage.mtv.corp.google.com>	
	<4A68013A.2020302@cn.fujitsu.com>
	<6599ad830907222327s31340956y9783db39d076520f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830907222327s31340956y9783db39d076520f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

>>>  static int cgroup_set_super(struct super_block *sb, void *data)
>>>  {
>>>       int ret;
>>> -     struct cgroupfs_root *root = data;
>>> +     struct cgroup_sb_opts *opts = data;
>>> +
>>> +     /* If we don't have a new root, we can't set up a new sb */
>>> +     if (!opts->new_root)
>>> +             return -EINVAL;
>>> +
>> I think this should be BUG_ON(). If set_super() is called,
>> we are allocating a new root, so opts->new_root won't be NULL.
> 
> Not true - if you try to mount a hierarchy by name, but with no
> subsystem options, then we don't construct a new root, but we still
> call sget(). If we find a superblock with the right name then we use
> it, else sget() will allocate a new superblock and call
> cgroup_set_super(), at which point we need to fail.
> 

Ah, I see.

>>> +             struct cgroupfs_root *new_root = cgroup_root_from_opts(&opts);
>> Why not just declare new_root in the beginning of cgroup_get_sb()?
> 
> Because it's not needed for the entire scope of the function. Keeping
> its scope as small as possible makes it clearer what it's being used
> for.
> 

If we had been doing this, we'll see many:

	(no if, while, for)
	{
		...
	}

in kernel code, but I don't remember I ever saw this style.
