From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [GIT PULL] cgroup changes for v3.15-rc1
Date: Fri, 4 Apr 2014 17:14:41 +0800
Message-ID: <533E7801.8090604@huawei.com>
References: <20140403164911.GE24119@htj.dyndns.org>
	<CA+55aFy1dm_CoTv+tihQ+m54G3gR9siOngurHsuKf9W3k1sKKw@mail.gmail.com>
	<CA+55aFwBm202pchEH9A6vbJVdar9-T35pBF44cCt7FNjmno9sQ@mail.gmail.com>
	<CAOS58YMckmoCocguf9BC_Wxbn3D2Rx3MArhgozO9qCj4g=5aDw@mail.gmail.com>
	<CA+55aFw2+VKojzoF2aDaruOMKHikTO8J0HeK9DoDLZr+HqTWbg@mail.gmail.com>
	<20140403194335.GC2472@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140403194335.GC2472-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2014/4/4 3:43, Tejun Heo wrote:
> Hello,
> 
> On Thu, Apr 03, 2014 at 12:01:23PM -0700, Linus Torvalds wrote:
>> [ Extending the participants list a bit ]
>>
>> On Thu, Apr 3, 2014 at 11:34 AM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>>> On the road so sending from phone. Iirc the param is necessary to
>>> distinguishe when a new sb is created so that it can be put properly later.
>>> I think cgroup is leaking super ref now and li was planning to send a fix
>>> once things are merged.
>>
>> So as far as I can tell, cgroup is fine, because the superblock itself
>> is properly refcounted by the mounting code. It's the magic hidden
> 
> Ah, I remembered the other way around.  We could leak cgroup_root
> reference, not the other way around.  cgroup_mount() can be called
> multiple times for the same sb and we inc cgroup_root's ref each time
> but cgroup_kill_sb() only happens when the sb is released, so if we do
> the following,
> 
>  # mkdir cpuset cpuset1
>  # mount -t cgroup -o cpuset cgroup cpuset
>  # mount -t cgroup -o cpuset cgroup cpuset1
>  # umount cpuset
>  # umount cpuset1
> 
> The cgroup_root should be destroyed but it isn't, I think.  We'd need
> to bump cgroup_root's refcnt only when a new sb is created.

Yeah, I had been waiting for the kernfs change to be merged into mainline,
so I can fix this cgroup refcnting, and here is the fix.

====================

[PATCH] cgroup: fix top cgroup refcnt leak

As mount() and kill_sb() is not a one-to-one match, If we mount the same
cgroupfs in serveral mount points, and then umount all of them, kill_sb()
will be called only once.

Try:
        # mount -t cgroup -o cpuacct xxx /cgroup
        # mount -t cgroup -o cpuacct xxx /cgroup2
        # cat /proc/cgroups | grep cpuacct
        cpuacct 2       1       1
        # umount /cgroup
        # umount /cgroup2
        # cat /proc/cgroups | grep cpuacct
        cpuacct 2       1       1

You'll see cgroupfs will never be freed.

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2189462..48bd9c9 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1487,6 +1487,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 	struct cgroup_sb_opts opts;
 	struct dentry *dentry;
 	int ret;
+	bool new_sb;
 
 	/*
 	 * The first time anyone tries to mount a cgroup, enable the list
@@ -1603,8 +1604,8 @@ out_unlock:
 	if (ret)
 		return ERR_PTR(ret);
 
-	dentry = kernfs_mount(fs_type, flags, root->kf_root, NULL);
-	if (IS_ERR(dentry))
+	dentry = kernfs_mount(fs_type, flags, root->kf_root, &new_sb);
+	if (IS_ERR(dentry) || !new_sb)
 		cgroup_put(&root->cgrp);
 	return dentry;
 }
-- 
1.8.0.2
