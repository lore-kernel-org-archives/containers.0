From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH RFC 00/48] Add namespace support for audit
Date: Mon, 10 Jun 2013 09:54:20 +0800
Message-ID: <51B531CC.2020604@cn.fujitsu.com>
References: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
	<519B3B4E.1070405@cn.fujitsu.com> <20130606215255.GA28978@tp>
	<20130606224710.GA30502@tp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130606224710.GA30502@tp>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
List-Id: containers.vger.kernel.org

On 06/07/2013 06:47 AM, Serge Hallyn wrote:
> Quoting Serge Hallyn (serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org):
>> Quoting Gao feng (gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
>>> On 05/07/2013 10:20 AM, Gao feng wrote:
>>>> This patchset try to add namespace support for audit.
>>>>
>>>> I choose to assign audit to the user namespace.
>>>> Right now,there are six kinds of namespaces, such as
>>>> net, mount, ipc, pid, uts and user. the first five
>>>> namespaces have special usage. the audit isn't suitable to
>>>> belong to these five namespaces, so the user namespace
>>>> may be the best choice.
>>>>
>>>> Through I decide to make audit related resources per user
>>>> namespace, but audit uses netlink to communicate between kernel
>>>> space and user space, and the netlink is a private resource
>>>> of per net namespace. So we need the capability to allow the
>>>> netlink sockets to communicate with each other in the same user
>>>> namespace even they are in different net namespace. [PATCH 2/48]
>>>> does this job, it adds a new function "compare" for per netlink
>>>> table to compare two sockets. it means the netlink protocols can
>>>> has its own compare fuction, For other protocols, two netlink
>>>> sockets are different if they belong to the different net namespace.
>>>> For audit protocol, two sockets can be the same even they in different
>>>> net namespace,we use user namespace not net namespace to make the
>>>> decision.
>>>>
>>>> There is one point that some people may dislike,in [PATCH 1/48],
>>>> the kernel side audit netlink socket is created only when we create
>>>> the first netns for the userns, and this userns will hold the netns
>>>> until we destroy this userns.
>>>>
>>>> The other patches just make the audit related resources per
>>>> user namespace.
>>>>
>>>> This patchset is sent as an RFC,any comments are welcome.
>>
>> Hi,
>>
>> thanks for sending this.  I think you need to ping the selinux folks
>> for comment though.  It appears to me that, after this patchset, the
>> kernel with CONFIG_USER_NS=y could not be LSPP-compliant, because
>> the selinux-generated audit messages do not always go to init_user_ns.
>>
>> Additionally, the only type of namespacing selinux wants is where it
>> is enforced by policy compiler and installer using typenames - i.e.
>> 'container1.user_t' vs 'user_t'.  Selinux does not want user namespaces
>> to affect selinux enforcement at all.  (at least last I knew, several
>> years ago at a mini-summit, I believe this was from Stephen Smalley).
> 
> That sort of sounds like I'm distancing myself from that, which I
> don't mean to do.  I agree with the decison:  MAC (selinux, apparmor
> and smack) should not be confuddled by user namespaces.  (posix caps
> are, as always, a bit different).


Thanks for your comments!

Very useful information, it sounds reasonable.

Let's just drop those patches.

Thanks,
Gao
> 
>> I think it's good to have userspace-generated audit messages (i.e.
>> auditctl -m 'hi there') sent to the same user namespace.  But the
>> selinux messages, near as I can tell, need to all go to init_user_ns.
>>
>> thanks,
>> -serge
>> _______________________________________________
>> Containers mailing list
>> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>> https://lists.linuxfoundation.org/mailman/listinfo/containers
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
