From: Rui Xiang <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/9] syslog_ns: make syslog handling per namespace
Date: Thu, 1 Aug 2013 11:10:26 +0800
Message-ID: <51F9D1A2.406@huawei.com>
References: <1375065080-26740-1-git-send-email-rui.xiang@huawei.com>
	<1375065080-26740-5-git-send-email-rui.xiang@huawei.com>
	<51F9BBAB.1080306@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51F9BBAB.1080306-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, libo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On 2013/8/1 9:36, Gao feng wrote:
> On 07/29/2013 10:31 AM, Rui Xiang wrote:
>> This patch makes syslog buf and other fields per
>> namespace.
>>
>> Here use ns->log_buf(log_buf_len, logbuf_lock,
>> log_first_seq, logbuf_lock, and so on) fields
>> instead of global ones to handle syslog.
>>
>> Syslog interfaces such as /dev/kmsg, /proc/kmsg,
>> and syslog syscall are all containerized for
>> container users.
>>
> 
> /dev/kmsg is used by the syslog api closelog, openlog, syslog, vsyslog,
> this should be per user namespace, but seems in your patch,

Yes, /dev/kmsg is per user namespace, and per syslog ns, too.

> the syslog message generated through these APIs on host can be exported
> to the /dev/kmsg of container, is this want we want?
>
Ah.. I think your question targets at devkmsg_writev function, right? 
You remind me that it's really an issue. Printk_emit in devkmsg_writev 
should not use init_syslog_ns as its syslog_ns but current_user_ns->syslog_ns.

In 1st version, current_syslog_ns was used in vprintk_emit. In this version,
the interface vprintk_emit has changed, but this patch misses that.
I will fix it.


Thanks for your reminder. :)
