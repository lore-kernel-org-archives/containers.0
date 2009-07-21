From: Danny Feng <dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix reverse unlock sequence in cgroup_get_sb
Date: Tue, 21 Jul 2009 19:12:54 +0800
Message-ID: <4A65A2B6.6050404__12052.202752284$1248174916$gmane$org@redhat.com>
References: <1248171926-20232-1-git-send-email-dfeng@redhat.com>
	<20090721111019.GV24157@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090721111019.GV24157-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 07/21/2009 07:10 PM, Balbir Singh wrote:
> * Xiaotian Feng<dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>  [2009-07-21 18:25:26]:
>
>> In cgroup_get_sb, the lock sequence is:
>> 	mutex_lock(&inode->i_mutex);
>> 	mutex_lock(&cgroup->mutex);
>> so the last unlock sequence should be:
>> 	mutex_unlock(&cgroup->mutex);
>> 	mutex_unlock(&inode->i_mutex);
>>
>> Signed-off-by: Xiaotian Feng<dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> ---
>>   kernel/cgroup.c |    2 +-
>>   1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
>> index 3737a68..11ef162 100644
>> --- a/kernel/cgroup.c
>> +++ b/kernel/cgroup.c
>> @@ -1140,8 +1140,8 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
>>   		BUG_ON(root->number_of_cgroups != 1);
>>
>>   		cgroup_populate_dir(root_cgrp);
>> -		mutex_unlock(&inode->i_mutex);
>>   		mutex_unlock(&cgroup_mutex);
>> +		mutex_unlock(&inode->i_mutex);
>>   	}
>>
>
> Seems reasonable to me. You might also want to mention that elsewhere
> the sequence is unlock cgroup_mutex followed by inode->i_mutex.
Yep, thank you very much:-)
>
> Acked-by: Balbir Singh<balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>
>
