From: Gu Zheng <guz.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/9] syslog_ns: add syslog_namespace and put/get_syslog_ns
Date: Tue, 30 Jul 2013 08:46:45 +0800
Message-ID: <51F70CF5.9090003@cn.fujitsu.com>
References: <1375065080-26740-1-git-send-email-rui.xiang@huawei.com>
	<1375065080-26740-2-git-send-email-rui.xiang@huawei.com>
	<51F6388B.8000308@cn.fujitsu.com> <51F65636.6080505@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51F65636.6080505-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rui Xiang <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, libo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On 07/29/2013 07:47 PM, Rui Xiang wrote:

> On 2013/7/29 17:40, Gu Zheng wrote:
>> Hi Rui,
>> 	Refer to inline:).
>>
> Hi Gu,
> 
> Thanks for your attention.
> 
>> On 07/29/2013 10:31 AM, Rui Xiang wrote:
>>
>>> Add a struct syslog_namespace which contains the necessary
>>> members for hanlding syslog and realize get_syslog_ns and
>>> put_syslog_ns API.
>>>
>>> Signed-off-by: Rui Xiang <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>> ---
>>>  include/linux/syslog.h | 68 ++++++++++++++++++++++++++++++++++++++++++++++++++
>>>  kernel/printk.c        |  7 ------
>>>  2 files changed, 68 insertions(+), 7 deletions(-)
>>>
> 
> ...
> 
>>> +
>>> +static inline void free_syslog_ns(struct kref *kref)
>>> +{
>>> +	struct syslog_namespace *ns;
>>> +	ns = container_of(kref, struct syslog_namespace, kref);
>>> +
>>> +	kfree(ns->log_buf);
>>> +	kfree(ns);
>>> +}
>>
>> This interface seems a bit ugly, why not use the format like put_syslog_ns()?
>>
>> static inline void free_syslog_ns(struct syslog_namespace *ns)
>>
> 
> Free_syslog_ns is used in put_syslog_ns. And the kref_put function uses kref as
> a parameter for its relase funtion. You can see that from 
> static inline int kref_put(struct kref *kref, void (*release)(struct kref *kref)).

Got it.

Regards,
Gu

> 
> Thanks.
> 
>>> +
>>> +static inline void put_syslog_ns(struct syslog_namespace *ns)
>>> +{
>>> +	if (ns)
>>> +		kref_put(&ns->kref, free_syslog_ns);
>>> +}
>>> +
>>>
> 
> 
