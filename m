From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC Part1 PATCH 00/20 v2] Add namespace support for audit
Date: Tue, 05 Nov 2013 15:51:55 +0800
Message-ID: <5278A39B.6000303@cn.fujitsu.com>
References: <1382599925-25143-1-git-send-email-gaofeng@cn.fujitsu.com>
	<5271D3FC.8000709@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5271D3FC.8000709-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: toshi.okajima-+CUm20s59erQFUHtdCDX3A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Ping...

On 10/31/2013 11:52 AM, Gao feng wrote:
> Hi Eric Paris,
> 
> Can you give me some comments?
> 
> You think the tying audit namespace to user namespace is a bad idea,
> so this patchset doesn't assign auditns to userns and introduce an
> new audit netlink type to help to create audit namespace.
> 
> and this patchset also introduces an new proc interface to make
> sure container can't influence the whole system.
> 
> and the audit rules are not namespace aware, all of audit namespaces
> should comply with the rules. in next step, if we find it's need to
> make audit rules per audit namespace, then it's the time to do that
> job.
> 
> This patchset also makes all of net namespaces have ability to send/
> receive audit netlink message.
> 
> I may miss some points, if you find there are some shortage or loophole,
> please let me know.
> 
> Thanks!
> 
> On 10/24/2013 03:31 PM, Gao feng wrote:
>> Here is the v1 patchset: http://lwn.net/Articles/549546/
>>
>> The main target of this patchset is allowing user in audit
>> namespace to generate the USER_MSG type of audit message,
>> some userspace tools need to generate audit message, or
>> these tools will broken.
>>
>> And the login process in container may want to setup
>> /proc/<pid>/loginuid, right now this value is unalterable
>> once it being set. this will also broke the login problem
>> in container. After this patchset, we can reset this loginuid
>> to zero if task is running in a new audit namespace.
>>
>> Same with v1 patchset, in this patchset, only the privileged
>> user in init_audit_ns and init_user_ns has rights to
>> add/del audit rules. and these rules are gloabl. all
>> audit namespace will comply with the rules.
>>
>> Compared with v1, v2 patch has some big changes.
>> 1, the audit namespace is not assigned to user namespace.
>>    since there is no available bit of flags for clone, we
>>    create audit namespace through netlink, patch[18/20]
>>    introduces a new audit netlink type AUDIT_CREATE_NS.
>>    the privileged user in userns has rights to create a
>>    audit namespace, it means the unprivileged user can
>>    create auditns through create userns first. In order
>>    to prevent them from doing harm to host, the default
>>    audit_backlog_limit of un-init-audit-ns is zero(means
>>    audit is unavailable in audit namespace). and it can't
>>    be changed in auditns through netlink.
>>
>> 2, introduce /proc/<pid>/audit_log_limit
>>    this interface is used to setup log_limit of audit
>>    namespace.  we need this interface to make audit
>>    available in un-init-audit-ns. Only the privileged user
>>    has right to set this value, it means only the root user
>>    of host can change it.
>>
>> 3, make audit namespace don't depend on net namespace.
>>    patch[1/20] add a compare function audit_compare for
>>    audit netlink, it always return true, it means the
>>    netlink subsystem will find out the netlink socket
>>    only through portid and netlink type. So we needn't
>>    to create kernel side audit netlink socket for per
>>    net namespace, all userspace audit netlink socket
>>    can find out the audit_sock, and audit_sock can
>>    communicate with them through the proper portid.
>>    it's just like the behavior we don't have net
>>    namespace before.
>>
>>
>> This patchset still need some work, such as allow changing
>> audit_enabled in audit namespace, auditd wants this feature.
>>
>> I send this patchset now in order to get more comments, so
>> I can keep on improving namespace support for audit.
>>
>> Gao feng (20):
>>   Audit: make audit netlink socket net namespace unaware
>>   audit: introduce configure option CONFIG_AUDIT_NS
>>   audit: make audit_skb_queue per audit namespace
>>   audit: make audit_skb_hold_queue per audit namespace
>>   audit: make audit_pid per audit namespace
>>   audit: make kauditd_task per audit namespace
>>   aduit: make audit_nlk_portid per audit namespace
>>   audit: make kaudit_wait queue per audit namespace
>>   audit: make audit_backlog_wait per audit namespace
>>   audit: allow un-init audit ns to change pid and portid only
>>   audit: use proper audit namespace in audit_receive_msg
>>   audit: use proper audit_namespace in kauditd_thread
>>   audit: introduce new audit logging interface for audit namespace
>>   audit: pass proper audit namespace to audit_log_common_recv_msg
>>   audit: Log audit pid config change in audit namespace
>>   audit: allow GET,SET,USER MSG operations in audit namespace
>>   nsproxy: don't make create_new_namespaces static
>>   audit: add new message type AUDIT_CREATE_NS
>>   audit: make audit_backlog_limit per audit namespace
>>   audit: introduce /proc/<pid>/audit_backlog_limit
>>
>>  fs/proc/base.c                  |  53 ++++++
>>  include/linux/audit.h           |  26 ++-
>>  include/linux/audit_namespace.h |  92 ++++++++++
>>  include/linux/nsproxy.h         |  15 +-
>>  include/uapi/linux/audit.h      |   1 +
>>  init/Kconfig                    |  10 ++
>>  kernel/Makefile                 |   2 +-
>>  kernel/audit.c                  | 364 +++++++++++++++++++++++++---------------
>>  kernel/audit.h                  |   5 +-
>>  kernel/audit_namespace.c        | 123 ++++++++++++++
>>  kernel/auditsc.c                |   6 +-
>>  kernel/nsproxy.c                |  18 +-
>>  12 files changed, 561 insertions(+), 154 deletions(-)
>>  create mode 100644 include/linux/audit_namespace.h
>>  create mode 100644 kernel/audit_namespace.c
>>
> 
> 
