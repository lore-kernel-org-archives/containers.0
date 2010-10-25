From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 2/7] cgroups: Allow to bind a subsystem to a cgroup
	hierarchy
Date: Mon, 25 Oct 2010 09:23:00 +0800
Message-ID: <4CC4DBF4.1030405@cn.fujitsu.com>
References: <4CC146A4.9090505@cn.fujitsu.com> <4CC146D4.7030009@cn.fujitsu.com>
	<20101022213819.GK10119@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101022213819.GK10119-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "akpm >> Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

>> +/*
>> + * cgroup_walk_herarchy - iterate through a cgroup hierarchy
>> + * @process_cgroup: callback called on each cgroup in the hierarchy
>> + * @data: will be passed to @process_cgroup
>> + * @top_cgrp: the root cgroup of the hierarchy
>> + *
>> + * For such a hierarchy:
>> + *        a1        c1
>> + *      /         /
>> + * Root - a2 - b1 - c2
>> + *      \
>> + *        a3
>> + *
>> + * The iterating order is: a1, a2, b1, c1, c2, a3. So a parent will be
>> + * processed before its children.
>> + */
> 
> You could just say it's a depth-first walk except we process the parent before
> its children.
> 

Will revise the comment. A diagram is intuitive. :)

>> +static int cgroup_walk_hierarchy(int (*process_cgroup)(struct cgroup *, void *),
>> +				 void *data, struct cgroup *top_cgrp)
> 
> <snip>
> 
>> +static int hierarchy_populate_dir(struct cgroup *cgrp, void *data)
>> +{
>> +	mutex_lock_nested(&cgrp->dentry->d_inode->i_mutex, I_MUTEX_CHILD);
>> +	cgroup_populate_dir(cgrp);
>> +	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
>> +	return 0;
>> +}
>> +
>>  /*
>>   * Call with cgroup_mutex held. Drops reference counts on modules, including
>>   * any duplicate ones that parse_cgroupfs_options took. If this function
>> @@ -945,36 +1079,53 @@ static int rebind_subsystems(struct cgroupfs_root *root,
>>  	unsigned long added_bits, removed_bits;
>>  	struct cgroup *cgrp = &root->top_cgroup;
>>  	int i;
>> +	int err;
>>
>>  	BUG_ON(!mutex_is_locked(&cgroup_mutex));
>>
>>  	removed_bits = root->actual_subsys_bits & ~final_bits;
>>  	added_bits = final_bits & ~root->actual_subsys_bits;
>> +
>>  	/* Check that any added subsystems are currently free */
>> -	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
>> -		unsigned long bit = 1UL << i;
>> -		struct cgroup_subsys *ss = subsys[i];
>> -		if (!(bit & added_bits))
>> -			continue;
>> +	for_each_set_bit(i, &added_bits, CGROUP_SUBSYS_COUNT) {
>>  		/*
>>  		 * Nobody should tell us to do a subsys that doesn't exist:
>>  		 * parse_cgroupfs_options should catch that case and refcounts
>>  		 * ensure that subsystems won't disappear once selected.
>>  		 */
>> -		BUG_ON(ss == NULL);
>> -		if (ss->root != &rootnode) {
>> +		BUG_ON(subsys[i] == NULL);
>> +		if (subsys[i]->root != &rootnode) {
>>  			/* Subsystem isn't free */
>>  			return -EBUSY;
>>  		}
>>  	}
>>
>> -	/* Currently we don't handle adding/removing subsystems when
>> -	 * any child cgroups exist. This is theoretically supportable
>> -	 * but involves complex error handling, so it's being left until
>> -	 * later */
>> -	if (root->number_of_cgroups > 1)
>> +	/* removing will be supported later */
>> +	if (root->number_of_cgroups > 1 && removed_bits)
>>  		return -EBUSY;
>>
>> +	if (root->number_of_cgroups > 1) {
> 
> Is there something wrong with the indentation here? I can't
> see the closing brace for the "if (root->number_of_cgroups > 1)"
> that should precede the for_each_set_bit() loop below.
> 

Oops, I must have forgot to commit the change when I fixed this.

>> +		for_each_set_bit(i, &added_bits, CGROUP_SUBSYS_COUNT)
>> +			if (!subsys[i]->can_bind)
>> +				return -EBUSY;
> 
> I think you could avoid the can_bind flag field entirely and do:
> 
> 			if (!subsys[i]->bind)
> 

Nope. For some subsystems we just set the flag and need not to
provide a bind() callback.

> Also, if we're going with my "split out unbind" suggestion I think
> the part here would be:
> 
> 		for_each_set_bit(i, &removed_bits, CGROUP_SUBSYS_COUNT)
> 			if (!subsys[i]->unbind)
> 				return -EBUSY;
> 
