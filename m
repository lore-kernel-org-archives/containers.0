From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 18/20] audit: add new message type AUDIT_CREATE_NS
Date: Mon, 09 Dec 2013 09:59:28 +0800
Message-ID: <52A52400.7060008@cn.fujitsu.com>
References: <1382599925-25143-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1382599925-25143-19-git-send-email-gaofeng@cn.fujitsu.com>
	<20131206221014.GC22445@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131206221014.GC22445-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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

On 12/07/2013 06:10 AM, Serge E. Hallyn wrote:
> Quoting Gao feng (gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
>> Since there is no more place for flags of clone system call.
>> we need to find a way to create audit namespace.
>>
>> this patch add a new type of message AUDIT_CREATE_NS.
>> user space can create new audit namespace through
>> netlink.
>>
>> Right now, The privileged user in user namespace is allowed
>> to create audit namespace. it means the unprivileged user can
>> create an user namespace and then create audit namespace.
>>
>> Looks like it is not safe, but even the unprivileged user can
>> create audit namespace, it can do no harm to the host. un-init
>> audit namespace cann't effect the host.
>>
>> In the follow patches, the audit_backlog_limit will be per
>> audit namesapace, but only the privileged user has rights to
>> modify it. and the default value of audit_backlog_limit for
>> uninit audit namespace will be set to 0.
>>
>> And the audit_rate_limit will be limited too.
>>
>> Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>> ---
>>  include/linux/audit_namespace.h |  7 +++++++
>>  include/uapi/linux/audit.h      |  1 +
>>  kernel/audit.c                  | 22 ++++++++++++++++++++++
>>  kernel/audit_namespace.c        | 29 +++++++++++++++++++++++++++++
>>  4 files changed, 59 insertions(+)
>>
>> diff --git a/include/linux/audit_namespace.h b/include/linux/audit_namespace.h
>> index 79a9b78..b17f052 100644
>> --- a/include/linux/audit_namespace.h
>> +++ b/include/linux/audit_namespace.h
>> @@ -54,6 +54,8 @@ void put_audit_ns(struct audit_namespace *ns)
>>  		rcu_read_unlock();
>>  	}
>>  }
>> +
>> +extern int unshare_audit_namespace(void);
>>  #else
>>  static inline
>>  struct audit_namespace *get_audit_ns(struct audit_namespace *ns)
>> @@ -66,6 +68,11 @@ void put_audit_ns(struct audit_namespace *ns)
>>  {
>>  
>>  }
>> +
>> +static inline int unshare_audit_namespace()
>> +{
>> +	return -EINVAL;
>> +}
>>  #endif
>>  
>>  static inline struct
>> diff --git a/include/uapi/linux/audit.h b/include/uapi/linux/audit.h
>> index 75cef3f..877d509 100644
>> --- a/include/uapi/linux/audit.h
>> +++ b/include/uapi/linux/audit.h
>> @@ -68,6 +68,7 @@
>>  #define AUDIT_MAKE_EQUIV	1015	/* Append to watched tree */
>>  #define AUDIT_TTY_GET		1016	/* Get TTY auditing status */
>>  #define AUDIT_TTY_SET		1017	/* Set TTY auditing status */
>> +#define AUDIT_CREATE_NS		1018	/* Create new audit namespace */
>>  
>>  #define AUDIT_FIRST_USER_MSG	1100	/* Userspace messages mostly uninteresting to kernel */
>>  #define AUDIT_USER_AVC		1107	/* We filter this differently */
>> diff --git a/kernel/audit.c b/kernel/audit.c
>> index c4d4291..86212d3 100644
>> --- a/kernel/audit.c
>> +++ b/kernel/audit.c
>> @@ -596,6 +596,12 @@ static int audit_netlink_ok(struct sk_buff *skb, u16 msg_type)
>>  		    !capable(CAP_AUDIT_CONTROL))
>>  			err = -EPERM;
>>  		break;
>> +	case AUDIT_CREATE_NS:
>> +		/* Allow privileged user in user namespace to
>> +		 * create audit namespace */
>> +		if (!ns_capable(current_user_ns(), CAP_AUDIT_CONTROL))
>> +			err = -EPERM;
>> +		break;
>>  	case AUDIT_USER:
>>  	case AUDIT_FIRST_USER_MSG ... AUDIT_LAST_USER_MSG:
>>  	case AUDIT_FIRST_USER_MSG2 ... AUDIT_LAST_USER_MSG2:
>> @@ -735,6 +741,22 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>>  		if (status_get->mask & AUDIT_STATUS_BACKLOG_LIMIT)
>>  			err = audit_set_backlog_limit(status_get->backlog_limit);
>>  		break;
>> +	case AUDIT_CREATE_NS:
>> +		err = unshare_audit_namespace();
>> +
>> +		if (audit_enabled == AUDIT_OFF)
>> +			break;
>> +
>> +		ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, AUDIT_CREATE_NS);
>> +		if (ab) {
>> +			audit_log_format(ab, "Create audit namespace");
>> +			audit_log_session_info(ab);
>> +			audit_log_task_context(ab);
>> +			audit_log_format(ab, "res=%d", err ? 0 : 1);
>> +			audit_log_end_ns(ns, ab);
>> +		}
>> +
>> +		break;
>>  	case AUDIT_USER:
>>  	case AUDIT_FIRST_USER_MSG ... AUDIT_LAST_USER_MSG:
>>  	case AUDIT_FIRST_USER_MSG2 ... AUDIT_LAST_USER_MSG2:
>> diff --git a/kernel/audit_namespace.c b/kernel/audit_namespace.c
>> index 6d9cb8f..28c608e 100644
>> --- a/kernel/audit_namespace.c
>> +++ b/kernel/audit_namespace.c
>> @@ -6,3 +6,32 @@ struct audit_namespace init_audit_ns = {
>>  	.user_ns = &init_user_ns,
>>  };
>>  EXPORT_SYMBOL_GPL(init_audit_ns);
>> +
>> +int unshare_audit_namespace(void)
>> +{
>> +	struct task_struct *tsk = current;
>> +	struct audit_namespace *new_audit = NULL;
>> +	struct nsproxy *new_nsp;
>> +
>> +	new_audit = kzalloc(sizeof(struct audit_namespace), GFP_KERNEL);
>> +	if (!new_audit)
>> +		return -ENOMEM;
>> +
>> +	skb_queue_head_init(&new_audit->queue);
>> +	skb_queue_head_init(&new_audit->hold_queue);
>> +	init_waitqueue_head(&new_audit->kauditd_wait);
>> +	init_waitqueue_head(&new_audit->backlog_wait);
>> +
>> +	new_nsp = create_new_namespaces(0, tsk, NULL, NULL);
>> +	if (IS_ERR(new_nsp)) {
>> +		kfree(new_audit);
>> +		return PTR_ERR(new_nsp);
>> +	}
>> +
>> +	new_audit->user_ns = get_user_ns(current_user_ns());
>> +	new_nsp->audit_ns = get_audit_ns(new_audit);
>> +
>> +	switch_task_namespaces(current, new_nsp);
> 
> Do you need to drop the old audit->ns refcount?
> 

task doesn't hold namespace's refcount directly. it hold ns's refcount
through nsproxy. switch_task_namespaces will release the refcount of old
nsproxy. so I think the refcount here is no problem.
