From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH RFC 00/48] Add namespace support for audit
Date: Tue, 11 Jun 2013 13:59:26 +0800
Message-ID: <51B6BCBE.7060608@cn.fujitsu.com>
References: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
	<519B3B4E.1070405@cn.fujitsu.com> <20130606215255.GA28978@tp>
	<20130606224710.GA30502@tp> <51B531CC.2020604@cn.fujitsu.com>
	<20130610212437.GA11940@austin.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130610212437.GA11940-anj0Drq5vpzx6HRWoRZK3AC/G2K4zDHf@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
List-Id: containers.vger.kernel.org

On 06/11/2013 05:24 AM, Serge E. Hallyn wrote:
> Quoting Gao feng (gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
>> On 06/07/2013 06:47 AM, Serge Hallyn wrote:
>>> Quoting Serge Hallyn (serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org):
>>>> Quoting Gao feng (gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
>>>>> On 05/07/2013 10:20 AM, Gao feng wrote:
>>>>>> This patchset try to add namespace support for audit.
>>>>>>
>>>>>> I choose to assign audit to the user namespace.
>>>>>> Right now,there are six kinds of namespaces, such as
>>>>>> net, mount, ipc, pid, uts and user. the first five
>>>>>> namespaces have special usage. the audit isn't suitable to
>>>>>> belong to these five namespaces, so the user namespace
>>>>>> may be the best choice.
>>>>>>
>>>>>> Through I decide to make audit related resources per user
>>>>>> namespace, but audit uses netlink to communicate between kernel
>>>>>> space and user space, and the netlink is a private resource
>>>>>> of per net namespace. So we need the capability to allow the
>>>>>> netlink sockets to communicate with each other in the same user
>>>>>> namespace even they are in different net namespace. [PATCH 2/48]
>>>>>> does this job, it adds a new function "compare" for per netlink
>>>>>> table to compare two sockets. it means the netlink protocols can
>>>>>> has its own compare fuction, For other protocols, two netlink
>>>>>> sockets are different if they belong to the different net namespace.
>>>>>> For audit protocol, two sockets can be the same even they in different
>>>>>> net namespace,we use user namespace not net namespace to make the
>>>>>> decision.
>>>>>>
>>>>>> There is one point that some people may dislike,in [PATCH 1/48],
>>>>>> the kernel side audit netlink socket is created only when we create
>>>>>> the first netns for the userns, and this userns will hold the netns
>>>>>> until we destroy this userns.
>>>>>>
>>>>>> The other patches just make the audit related resources per
>>>>>> user namespace.
>>>>>>
>>>>>> This patchset is sent as an RFC,any comments are welcome.
>>>>
>>>> Hi,
>>>>
>>>> thanks for sending this.  I think you need to ping the selinux folks
>>>> for comment though.  It appears to me that, after this patchset, the
>>>> kernel with CONFIG_USER_NS=y could not be LSPP-compliant, because
>>>> the selinux-generated audit messages do not always go to init_user_ns.
>>>>
>>>> Additionally, the only type of namespacing selinux wants is where it
>>>> is enforced by policy compiler and installer using typenames - i.e.
>>>> 'container1.user_t' vs 'user_t'.  Selinux does not want user namespaces
>>>> to affect selinux enforcement at all.  (at least last I knew, several
>>>> years ago at a mini-summit, I believe this was from Stephen Smalley).
>>>
>>> That sort of sounds like I'm distancing myself from that, which I
>>> don't mean to do.  I agree with the decison:  MAC (selinux, apparmor
>>> and smack) should not be confuddled by user namespaces.  (posix caps
>>> are, as always, a bit different).
>>
>>
>> Thanks for your comments!
>>
>> Very useful information, it sounds reasonable.
>>
>> Let's just drop those patches.
>>
> 
> Hi Gao,
> 
> proceeding then,
> 
> The netfilter related changes I think make sense.  They log to the userns
> which owns the netns in question, which seems right.
> 
> However looking at Audit-tty-translate-audit_log_start-to-audit_log_sta.patch,
> it appears to log to the userns of the task which is doing the operation.
> 
> Keeping in mind that an unprivileged user can create a new user namespace,
> this doesn't seem right.
> 
> Also, you are introducing per-userns syscall filter.  It looks like I
> can then create a new userns to escape my existing syscall filter, since
> the filters up the user_ns parent chain are not being applied.  Is that
> correct?

Hi Serge,

I admit that the global resources related audit message should be logged to
parent and ancestor. but this is more complex than the way I implemented.
Because we should send message to all ancestor and we should consider not
to exceed the rate_limit of all ancestor.

I prefer to don't make these filters/rules per user namespace right now.

> 
> Did you have a particular rationale written out for what precisely you're
> wanting to make per-userns?  That would be helpful in trying to figure
> out which bits are appropriate.  Again I so far haven't seen a single
> problem with the code itself, it's just a question of which bits we
> actually want (and are safe).
> 

In my option, the audit rules(inode, tree_list, filter) , some of audit
controller related resources(enabled,pid,portid...) and skb queue, audit
netlink sockets,kauditd thread should be per-userns. The audit user message
which generated by the user in container should be per-userns too.

Since netns is not implemented as a hierarchy, and the network related
resources are not global. so network related audit message should be per-userns too.

The security related audit message should be send to init user namespace
as we discussed before. Maybe tty related audit message should be send
to init user namespace too, I have no idea now.

The next step, I will post a new patchset which only make the audit user
message and the basic audit resource per userns. I think this patchset
will easy to be reviewed and accepted, And will not influence the host.
This patchset contains the below patches:

Gao feng (21):
  Audit: make audit kernel side netlink sock per userns
  netlink: Add compare function for netlink_table
  Audit: implement audit self-defined compare function
  Audit: make audit_skb_queue per user namespace
  Audit: make audit_skb_hold_queue per user namespace
  Audit: make kauditd_task per user namespace
  Audit: make audit_pid per user namespace
  Audit: make audit_nlk_portid per user namesapce
  Audit: make audit_enabled per user namespace
  Audit: make audit_ever_enabled per user namespace
  Audit: make audit_initialized per user namespace
  Audit: only allow init user namespace to change rate limit
  Audit: only allow init user namespace to change audit_failure
  Audit: allow to send netlink message to auditd in uninit user
    namespace
  Audit: make kauditd_wait per user namespace
  Audit: make audit_backlog_wait per user namespace
  Audit: introduce new audit logging interface for user namespace
  Audit: pass proper user namespace to audit_log_common_recv_msg
  Audit: Log audit config change in uninit user namespace
  Audit: send reply message to the auditd in proper user namespace
  Audit: Allow GET,SET,USER MSG operations in uninit user namespace

 include/linux/audit.h          |  39 +++-
 include/linux/netlink.h        |   1 +
 include/linux/user_namespace.h |  33 +++-
 kernel/audit.c                 | 422 ++++++++++++++++++++++++++---------------
 kernel/audit.h                 |   5 +-
 kernel/auditsc.c               |  11 +-
 kernel/user_namespace.c        |   3 +
 net/netlink/af_netlink.c       |  32 +++-
 net/netlink/af_netlink.h       |   1 +
 9 files changed, 369 insertions(+), 178 deletions(-)

Do you have any comments or advice to this plan? After the above patchs
been accepted, I think it's easy to push other audit namespace related
patches into upstream.

Thanks,
Gao

> -serge
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
