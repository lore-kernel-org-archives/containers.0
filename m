From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: superblock can't be released with active dentries
Date: Mon, 28 May 2012 08:18:08 +0800
Message-ID: <4FC2C440.8090104@huawei.com>
References: <20120330223423.GJ28934@google.com>
	<20120330223606.GK28934@google.com> <4F77B6BA.4070207@huawei.com>
	<20120401185430.GA9230@dhcp-172-17-108-109.mtv.corp.google.com>
	<CA+1xoqe5hMuxzCRhMy7J0XchDk2ZnuxOHJKikROk1-ReAzcT6g@mail.gmail.com>
	<20120518175548.GM19388@google.com>
	<CA+1xoqfr5aaGbxoX3YKrJHXTjU9fWSbX_xbuEOU=4K7kMay6XQ@mail.gmail.com>
	<20120523222242.GD3933@htj.dyndns.org>
	<CA+1xoqdbtkC5Ue3s1qZHHJBLcj9a=djFDGny6AJJSV-pdn7mcA@mail.gmail.com>
	<20120524154139.GA27983@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-reply-to: <20120524154139.GA27983-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

2012/5/24 23:41, Tejun Heo wrote:

>>From 88787c483106c5830a46d18deaffdc1e70929af7 Mon Sep 17 00:00:00 2001
> From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Date: Thu, 24 May 2012 08:24:39 -0700
> 
> 48ddbe1946 "cgroup: make css->refcnt clearing on cgroup removal
> optional" allowed a css to linger after the associated cgroup is
> removed.  As a css holds a reference on the cgroup's dentry, it means
> that cgroup dentries may linger for a while.
> 
> cgroup_create() does grab an active reference on the superblock to
> prevent it from going away while there are !root cgroups; however, the
> reference is put from cgroup_diput() which is invoked on cgroup
> removal, so cgroup dentries which are removed but persisting due to
> lingering csses already have released their superblock active refs
> allowing superblock to be killed while those dentries are around.
> 
> Given the right condition, this makes cgroup_kill_sb() call
> kill_litter_super() with dentries with non-zero d_count leading to
> BUG() in shrink_dcache_for_umount_subtree().
> 
> Fix it by adding cgroup_dops->d_release() operation and moving
> deactivate_super() to it.  cgroup_diput() now marks dentry->d_fsdata
> with itself if superblock should be deactivated and cgroup_d_release()
> deactivates the superblock on dentry release.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Reported-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Tested-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> LKML-Reference: <CA+1xoqe5hMuxzCRhMy7J0XchDk2ZnuxOHJKikROk1-ReAzcT6g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>


Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
