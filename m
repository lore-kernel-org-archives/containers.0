From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH] memcg: fix a race when setting memcg.swappiness
Date: Wed, 14 Jan 2009 14:47:18 +0800
Message-ID: <496D8A76.9040509__38131.2407822863$1231915853$gmane$org@cn.fujitsu.com>
References: <496D5AE2.2020403@cn.fujitsu.com>
	<20090114132616.3cb7d568.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090114132616.3cb7d568.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> On Wed, 14 Jan 2009 11:24:18 +0800
> Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> 
>> (suppose: memcg->use_hierarchy == 0 and memcg->swappiness == 60)
>>
>> echo 10 > /memcg/0/swappiness   |
>>   mem_cgroup_swappiness_write() |
>>     ...                         | echo 1 > /memcg/0/use_hierarchy
>>                                 | mkdir /mnt/0/1
>>                                 |   sub_memcg->swappiness = 60;
>>     memcg->swappiness = 10;     |
>>
>> In the above scenario, we end up having 2 different swappiness
>> values in a single hierarchy.
>>
>> Note we can't use hierarchy_lock here, because it doesn't protect
>> the create() method.
>>
>> Though IMO use cgroup_lock() in simple write functions is OK,
>> Paul would like to avoid it. And he sugguested use a counter to
>> count the number of children instead of check cgrp->children list:
>>
>> =================
>> create() does:
>>
>> lock memcg_parent
>> memcg->swappiness = memcg->parent->swappiness;
>> memcg_parent->child_count++;
>> unlock memcg_parent
>>
>> and write() does:
>>
>> lock memcg
>> if (!memcg->child_count) {
>>   memcg->swappiness = swappiness;
>> } else {
>>   report error;
>> }
>> unlock memcg
>>
>> destroy() does:
>> lock memcg_parent
>> memcg_parent->child_count--;
>> unlock memcg_parent
>>
>> =================
>>
>> And there is a suble differnce with checking cgrp->children,
>> that a cgroup is removed from parent's list in cgroup_rmdir(),
>> while memcg->child_count is decremented in cgroup_diput().
>>
>>
>> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> 
> Seems reasonable, but, hmm...
> 

Do you mean you agree to avoid using cgroup_lock()?

> Why hierarchy_mutex can't be used for create() ?
> 

We can make hierarchy_mutex work for this race by:

@@ -2403,16 +2403,18 @@ static long cgroup_create(struct cgroup *parent, struct
        if (notify_on_release(parent))
                set_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);

+       cgroup_lock_hierarchy(root);
+
        for_each_subsys(root, ss) {
                struct cgroup_subsys_state *css = ss->create(ss, cgrp);
                if (IS_ERR(css)) {
+                       cgroup_unlock_hierarchy(root);
                        err = PTR_ERR(css);
                        goto err_destroy;
                }
                init_cgroup_css(css, ss, cgrp);
        }

-       cgroup_lock_hierarchy(root);
        list_add(&cgrp->sibling, &cgrp->parent->children);
        cgroup_unlock_hierarchy(root);
        root->number_of_cgroups++;

But this may not be what we want, because hierarchy_mutex is meant to be
lightweight, so it's not held while subsys callbacks are invoked, except
bind().
