From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup for disk quota
Date: Fri, 20 Feb 2009 14:45:39 +0100
Message-ID: <499EB403.9050403@fr.ibm.com>
References: <d95d44a20902200028h1e229cc0pa3cdd4f42814e78e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <d95d44a20902200028h1e229cc0pa3cdd4f42814e78e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

anqin wrote:
> Dear Daniel and Serge,
> 
> For unified management of resources (CPU, memory, disk, network),
> I (and Ian) developed a cgroup subsystem to control the usage
> of disk quota.
> 
> The subsystem for disk quota (disk_cgroup, to be brief) does accounting
> of inode and block allocated by ext3/ext2 filesystem. Simarily as
> filesystem quota, the disk_cgroup can do limitation but without needing
> to open filesytem quota options (e.g. usrquota,grpquota in /etc/fstab).
> Since this patch is first developed, it needs more feedback and testing
> from other developers or users.


Cool, that looks like a very interesting feature :)

> The simple usage of disk_cgroup is as follows:
> 
> # mount -t cgroup cgroup /mnt/cgrp
> # lxc-execute -n lxc-template.conf /bin/bash
> # ls /mnt/cgrp/11457/		// <--  11457 is the pid of bash
> ...
> disk.stat
> disk.usage_in_inode
> disk.usage_in_block
> disk.max_usage_in_inode
> disk.max_usage_in_block
> disk.limit_in_inode
> disk.limit_in_inode
> ...
> 
> # echo  3 > /mnt/cgrp/11457/disk.max_usage_in_block
> 
> # touch /tmp/mytestfile1
> # touch /tmp/mytestfile2
> # touch /tmp/mytestfile3
> # touch /tmp/mytestfile4
> touch: cannot touch `/tmp/mytestfile4': Disk quota exceeded
> 
> The disk_cgroup is easily extended to manage complex objects
> of filesystem.
> 
> BTW, I don't know how to submit a "useful" patch to kernel community. Or,
> maybe the patch is not useful at all and maybe has been developed by other
> developers. I very appreciate if both of experts could give me some commend.
> I will continue to develop cgroup-related codes to make contribution to kernel
> development.

I am not sure I understand what you mean by "useful", but it seems you 
did an interesting feature. All the documentation related to submitting 
patches is in Documentation/SubmittingPatches, I hope that helps.

send your patches to lkml@ prefixed with [RFC] in the subject ('quilt' 
is your friend). If the functionality already exists, someone will tell you.

Thanks.
  -- Daniel
