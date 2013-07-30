From: Gu Zheng <guz.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 7/9] syslog_ns: implement function for creating syslog ns
Date: Tue, 30 Jul 2013 11:42:34 +0800
Message-ID: <51F7362A.3030509@cn.fujitsu.com>
References: <1375065080-26740-1-git-send-email-rui.xiang@huawei.com>
	<1375065080-26740-8-git-send-email-rui.xiang@huawei.com>
	<51F64313.4010700@cn.fujitsu.com> <51F73555.1020204@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51F73555.1020204-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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

On 07/30/2013 11:39 AM, Rui Xiang wrote:

> On 2013/7/29 18:25, Gu Zheng wrote:
>> Hi Rui,
>>
>> On 07/29/2013 10:31 AM, Rui Xiang wrote:
>>
>>> Add create_syslog_ns function to create a new ns. We
>>> must create a user_ns before create a new syslog ns.
>>> And then tie the new syslog_ns to current user_ns
>>> instead of original syslog_ns which comes from
>>> parent user_ns.
> 
> ...
> 
>>> diff --git a/kernel/printk.c b/kernel/printk.c
>>> index fd2d600..6b561db 100644
>>> --- a/kernel/printk.c
>>> +++ b/kernel/printk.c
>>> @@ -384,6 +384,10 @@ static int check_syslog_permissions(int type, bool from_file,
>>>  		|| type == SYSLOG_ACTION_CONSOLE_LEVEL)
>>>  		ns = &init_syslog_ns;
>>>  
>>> +	/* create a new syslog ns */
>>> +	if (type == SYSLOG_ACTION_NEW_NS)
>>> +		return 0;
>>> +
>>
>> Don't we need further permission or caps check here? Return success directly seems sloppy. 
>>
> CAP_SYSLOG is checked in create_syslog_ns, so I think we can return 0 temporarily.

If so, why not move the check here? IMO, permission checking is the earlier the better,
what's your opinion?

Regards,
Gu

> 
> 
> 
> 
