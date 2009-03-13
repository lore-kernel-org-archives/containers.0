From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] devcgroup: avoid using cgroup_lock
Date: Fri, 13 Mar 2009 09:54:15 +0800
Message-ID: <49B9BCC7.7090908__36145.4986189075$1236909513$gmane$org@cn.fujitsu.com>
References: <49B869BB.7030907@cn.fujitsu.com>
	<20090312181912.GA20144@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090312181912.GA20144-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

>> @@ -426,11 +431,11 @@ static int devcgroup_access_write(struct cgroup *cgrp, struct cftype *cft,
>>  				  const char *buffer)
>>  {
>>  	int retval;
>> -	if (!cgroup_lock_live_group(cgrp))
> 
> Does it matter that we no longer check for cgroup_is_removed()?
> 

No, this means in a rare case that the write handler is called when the cgroup
is dead, we still do the update work instead of returning ENODEV.

This is ok, since at that time, accessing cgroup and devcgroup is still valid,
but will have no effect since there is no task in this cgroup and the cgroup
will be destroyed soon.

>> -		return -ENODEV;
>> +
>> +	mutex_lock(&devcgroup_mutex);
>>  	retval = devcgroup_update_access(cgroup_to_devcgroup(cgrp),
>>  					 cft->private, buffer);
>> -	cgroup_unlock();
>> +	mutex_unlock(&devcgroup_mutex);
>>  	return retval;
>>  }
