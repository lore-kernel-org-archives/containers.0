From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 2/9] syslog_ns: add syslog_ns into user_namespace
Date: Mon, 29 Jul 2013 17:54:26 +0800
Message-ID: <51F63BD2.6090902@cn.fujitsu.com>
References: <1375065080-26740-1-git-send-email-rui.xiang@huawei.com>
	<1375065080-26740-3-git-send-email-rui.xiang@huawei.com>
	<51F639FB.304@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51F639FB.304-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gu Zheng <guz.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, libo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On 07/29/2013 05:46 PM, Gu Zheng wrote:
> Hi Rui,
> 
> On 07/29/2013 10:31 AM, Rui Xiang wrote:
> 
>> Add a syslog_ns pointer to user_namespace, and make
>> syslog_ns per user_namespace, not global.
>>
>> Since syslog_ns is assigned to user_ns, we can have
>> full capabilities in new user_ns to create a new syslog_ns.
>>
>> Signed-off-by: Rui Xiang <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>> ---
>>  include/linux/syslog.h         | 5 +++++
>>  include/linux/user_namespace.h | 1 +
>>  2 files changed, 6 insertions(+)
>>
>> diff --git a/include/linux/syslog.h b/include/linux/syslog.h
>> index 425fafe..62ce47f 100644
>> --- a/include/linux/syslog.h
>> +++ b/include/linux/syslog.h
>> @@ -90,6 +90,11 @@ struct syslog_namespace {
>>  	size_t syslog_partial;
>>  
>>  	int dmesg_restrict;
>> +
>> +	/*
>> +	 * user namespace which owns this syslog ns.
>> +	 */
>> +	struct user_namespace *owner;
>>  };
>>  
>>  static inline struct syslog_namespace *get_syslog_ns(
>> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
>> index b6b215f..ce2de5b 100644
>> --- a/include/linux/user_namespace.h
>> +++ b/include/linux/user_namespace.h
>> @@ -28,6 +28,7 @@ struct user_namespace {
>>  	unsigned int		proc_inum;
>>  	bool			may_mount_sysfs;
>>  	bool			may_mount_proc;
>> +	struct syslog_namespace *syslog_ns;
> 
> As we add a syslog_ns pointer to user_namespace to make
> syslog_ns per user_namespace and the caps check.
> But why also add a point to syslog_namespace in
> user_namespace? Am I missing something?:)
> 

yep,with this we can make sure all the other types of namespace such as mount, net, pid
can access syslog_ns through user namespace.
