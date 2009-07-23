From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 4/4] Allow cgroup hierarchies to be created with no bound
	subsystems
Date: Thu, 23 Jul 2009 16:32:17 +0800
Message-ID: <4A682011.5010400__20145.12678511$1248338155$gmane$org@cn.fujitsu.com>
References: <20090722194644.7481.47805.stgit@menage.mtv.corp.google.com>	<20090722195045.7481.62013.stgit@menage.mtv.corp.google.com>
	<20090723171913.3279de8c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090723171913.3279de8c.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

>> -	/* We can't have an empty hierarchy */
>> +
>> +	/* Can't specify "none" and some subsystems */
>> +	if (opts->subsys_bits && opts->none)
>> +		return -EINVAL;
> 
> Is this case never happens ?
> 
> 	BUG_ON(!opts->subsys_bits && !opts->none)
> 

It can happen:

  # mount -t cgroup -o none,memory

> 
>> +
>> +	/*
>> +	 * We either have to specify by name or by subsystems. (So all
>> +	 * empty hierarchies must have a name).
>> +	 */
>>  	if (!opts->subsys_bits && !opts->name)
>>  		return -EINVAL;
>>  
>> @@ -1129,6 +1124,31 @@ static void init_cgroup_root(struct cgroupfs_root *root)
>>  	init_cgroup_housekeeping(cgrp);
>>  }
>>  
>> +static bool init_root_id(struct cgroupfs_root *root)
>> +{
>> +	int ret = 0;
>> +
>> +	do {
>> +		if (!ida_pre_get(&hierarchy_ida, GFP_KERNEL))
>> +			return false;
>> +		spin_lock(&hierarchy_id_lock);
>> +		/* Try to allocate the next unused ID */
>> +		ret = ida_get_new_above(&hierarchy_ida, next_hierarchy_id,
>> +					&root->hierarchy_id);
> 
> Why new id should be greater than old one ?
> Just for avoiding reuse-id-too-soon ?
> 

Otherwise we can't identify each hierachy by it's id.


>> +		if (ret == -ENOSPC)
>> +			/* Try again starting from 0 */
>> +			ret = ida_get_new(&hierarchy_ida, &root->hierarchy_id);
>> +		if (!ret) {
>> +			next_hierarchy_id = root->hierarchy_id + 1;
>> +		} else if (ret != -EAGAIN) {
>> +			/* Can only get here if the 31-bit IDR is full ... */
>> +			BUG_ON(ret);
>> +		}
>> +		spin_unlock(&hierarchy_id_lock);
>> +	} while (ret);
>> +	return true;
>> +}
>> +

...

>> @@ -3910,8 +3950,8 @@ static int current_css_set_cg_links_read(struct cgroup *cont,
>>  			name = c->dentry->d_name.name;
>>  		else
>>  			name = "?";
>> -		seq_printf(seq, "Root %lu group %s\n",
>> -			   c->root->subsys_bits, name);
>> +		seq_printf(seq, "Root %d group %s\n",
>> +			   c->root->hierarchy_id, name);
>>  	}
> 
> I'm not sure but this "id" is worth to be printed ?
> 

It's a debug file, so I think at least it's not bad to print the id.
