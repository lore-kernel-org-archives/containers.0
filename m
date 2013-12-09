From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 16/20] audit: allow GET, SET, USER MSG operations in audit
	namespace
Date: Mon, 09 Dec 2013 09:47:50 +0800
Message-ID: <52A52146.1060804@cn.fujitsu.com>
References: <1382599925-25143-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1382599925-25143-17-git-send-email-gaofeng@cn.fujitsu.com>
	<20131206220033.GB22445@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131206220033.GB22445-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: toshi.okajima-+CUm20s59erQFUHtdCDX3A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 12/07/2013 06:00 AM, Serge E. Hallyn wrote:
> Quoting Gao feng (gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
>> 1, remove the permission check of pid namespace. it's no reason
>>    to deny un-init pid namespace to operate audit subsystem.
>>
>> 2, only allow init user namespace and init audit namespace to
>>    operate list/add/del rule, tty set, trim, make equiv operations.
>>
>> 3, allow audit namespace to get/set audit configuration, send
>>    userspace audit message.
>>
>> Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>> ---
>>  kernel/audit.c | 13 ++++++-------
>>  1 file changed, 6 insertions(+), 7 deletions(-)
>>
>> diff --git a/kernel/audit.c b/kernel/audit.c
>> index 095f54d..c4d4291 100644
>> --- a/kernel/audit.c
>> +++ b/kernel/audit.c
>> @@ -573,11 +573,7 @@ out:
>>  static int audit_netlink_ok(struct sk_buff *skb, u16 msg_type)
>>  {
>>  	int err = 0;
>> -
>> -	/* Only support the initial namespaces for now. */
>> -	if ((current_user_ns() != &init_user_ns) ||
>> -	    (task_active_pid_ns(current) != &init_pid_ns))
>> -		return -EPERM;
>> +	struct audit_namespace *ns = current->nsproxy->audit_ns;
>>  
>>  	switch (msg_type) {
>>  	case AUDIT_LIST:
>> @@ -586,6 +582,7 @@ static int audit_netlink_ok(struct sk_buff *skb, u16 msg_type)
>>  		return -EOPNOTSUPP;
>>  	case AUDIT_GET:
>>  	case AUDIT_SET:
>> +		break;
> 
> So, these AUDIT_SET and AUDIT_GET go from requiring CAP_AUDIT_CONTROL
> to not needing any privs at all?
> 

My mistake, there should be a check such as
ns_capable(ns, CAP_AUDIT_CONTROL).

will fix in next version.

Thanks!
