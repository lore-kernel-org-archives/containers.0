From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH cgroup 1/2] cgroup: move module ref handling into
	rebind_subsystems()
Date: Fri, 12 Jul 2013 17:08:23 +0800
Message-ID: <51DFC787.7080703@huawei.com>
References: <20130629041231.GA31353@htj.dyndns.org>
	<51DFC650.9010801@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51DFC650.9010801-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

>> Subject: [PATCH 1/2] cgroup: move module ref handling into rebind_subsystems()
>>
>> Module ref handling in cgroup is rather weird.
>> parse_cgroupfs_options() grabs all the modules for the specified
>> subsystems.  A module ref is kept if the specified subsystem is newly
>> bound to the hierarchy.  If not, or the operation fails, the refs are
>> dropped.  This scatters module ref handling across multiple functions
>> making it difficult to track.  It also make the function nasty to use
>> for dynamic subsystem binding which is necessary for the planned
>> unified hierarchy.
>>
>> There's nothing which requires the subsystem modules to be pinned
>> between parse_cgroupfs_options() and rebind_subsystems() in both mount
>> and remount paths.  parse_cgroupfs_options() can just parse and
>> rebind_subsystems() can handle pinning the subsystems that it wants to
>> bind, which is a natural part of its task - binding - anyway.
>>
>> Move module ref handling into rebind_subsystems() which makes the code
>> a lot simpler - modules are gotten iff it's gonna be bound and put iff
>> unbound or binding fails.
>>
>> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>> ---
>>  kernel/cgroup.c | 87 +++++++++++++++------------------------------------------
>>  1 file changed, 22 insertions(+), 65 deletions(-)
>>
>> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
>> index 3bc7a1a..a65aff1 100644
>> --- a/kernel/cgroup.c
>> +++ b/kernel/cgroup.c
>> @@ -1003,6 +1003,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
>>  {
>>  	struct cgroup *cgrp = &root->top_cgroup;
>>  	struct cgroup_subsys *ss;
>> +	unsigned long pinned = 0;
>>  	int i, ret;
>>  
>>  	BUG_ON(!mutex_is_locked(&cgroup_mutex));
>> @@ -1010,20 +1011,26 @@ static int rebind_subsystems(struct cgroupfs_root *root,
>>  
>>  	/* Check that any added subsystems are currently free */
>>  	for_each_subsys(ss, i) {
>> -		unsigned long bit = 1UL << i;
>> -
>> -		if (!(bit & added_mask))
>> +		if (!(added_mask & (1 << i)))
>>  			continue;
>>  
>> +		/* is the subsystem mounted elsewhere? */
>>  		if (ss->root != &cgroup_dummy_root) {
>> -			/* Subsystem isn't free */
>> -			return -EBUSY;
>> +			ret = -EBUSY;
>> +			goto out_put;
>>  		}
>> +
>> +		/* pin the module */
>> +		if (!try_module_get(ss->module)) {
>> +			ret = -ENOENT;
>> +			goto out_put;
>> +		}
>> +		pinned |= 1 << i;
>>  	}
> 
> This looks wrong to me.
> 
> cgroup_mount()
> {
> 	mutex_lock(cgroup_mutex);
> 	parse_cgroupfs_options();
> 	mutex_unlock(cgroup_mutex);
> 	...
> 
> 	mutex_lock(cgroup_mutex);
> 	...
> 	rebind_subsystems();
> 	...
> 	mutex_unlock(cgroup_mutex);
> }
> 
> so a modular cgroup subsystem can be unloaded inbetween, say it's net_cls, and
> then it's possible that:
> 
> 	# mount -t cgroup -o net_cls xxx /cgroup
> 
> The above operation succeeds but it's not binded to cgroupfs as it just got
> unloaded.
> 

for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
	...
	if (!subsys[i] && (added_mask & (1 << i))
		return -EINVAL;
	...
}

This should work.
