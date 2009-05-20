From: "IKEDA, Munehiro" <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
Subject: Re: [PATCH] IO Controller: Add per-device weight and ioprio_class
	handling
Date: Wed, 20 May 2009 11:41:19 -0400
Message-ID: <4A14249F.9080105@ds.jp.nec.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<4A0A29B5.7030109@cn.fujitsu.com>
	<20090513190929.GB18371@redhat.com>
	<4A0BC7AB.8030703@cn.fujitsu.com> <4A11E244.2000305@ds.jp.nec.com>
	<4A136090.5090705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A136090.5090705-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Gui Jianfeng wrote:
> IKEDA, Munehiro wrote:
>> Hi Gui,
>>
>> Gui Jianfeng wrote:
>>> Hi Vivek,
>>>
>>> This patch enables per-cgroup per-device weight and ioprio_class
>>> handling.
>>> A new cgroup interface "policy" is introduced. You can make use of
>>> this file to configure weight and ioprio_class for each device in a
>>> given cgroup.
>>> The original "weight" and "ioprio_class" files are still available. If
>>> you
>>> don't do special configuration for a particular device, "weight" and
>>> "ioprio_class" are used as default values in this device.
>>>
>>> You can use the following format to play with the new interface.
>>> #echo DEV:weight:ioprio_class > /patch/to/cgroup/policy
>>> weight=0 means removing the policy for DEV.
>>>
>>> Examples:
>>> Configure weight=300 ioprio_class=2 on /dev/hdb in this cgroup
>>> # echo /dev/hdb:300:2 > io.policy
>>> # cat io.policy
>>> dev weight class
>>> /dev/hdb 300 2
>> Users can specify a device file of a partition for io.policy.
>> In this case, io_policy_node::dev_name is set as a name of the
>> partition device like /dev/sda2.
>>
>> ex)
>>  # cd /mnt/cgroup
>>  # cat /dev/sda2:500:2 > io.policy
>>  # echo io.policy
>>    dev weight class
>>    /dev/sda2 500 2
>>
>> I believe io_policy_node::dev_name should be set a generic
>> device name like /dev/sda.
>> What do you think about it?
> 
>   Hi Ikeda-san,
> 
>   Sorry for the late reply. Thanks for pointing this out. 
>   yes, it does the right thing but shows a wrong name. 
>   IMHO, Inputing a sigle partition should not be allowed since the
>   policy is disk basis. So how about the following patch?
> 
> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
> index 1a0ca07..b620768 100644
> --- a/block/elevator-fq.c
> +++ b/block/elevator-fq.c
> @@ -1650,6 +1650,9 @@ static int devname_to_devnum(const char *buf, dev_t *dev)
>  		return -ENODEV;
>  
>  	disk = get_gendisk(bdev->bd_dev, &part);
> +	if (part)
> +		return -EINVAL;
> +
>  	*dev = MKDEV(disk->major, disk->first_minor);
>  	bdput(bdev);
> 

It looks nicer and reasonable for me.
Thanks!



-- 
IKEDA, Munehiro
 NEC Corporation of America
   m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org
