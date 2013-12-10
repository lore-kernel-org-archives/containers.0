From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC Part1 PATCH 00/20 v2] Add namespace support for audit
Date: Tue, 10 Dec 2013 16:16:33 +0800
Message-ID: <52A6CDE1.8090404@cn.fujitsu.com>
References: <1382599925-25143-1-git-send-email-gaofeng@cn.fujitsu.com>
	<529EE877.7030701@cn.fujitsu.com>
	<20131206221241.GD22445@mail.hallyn.com>
	<52A52599.3070502@cn.fujitsu.com> <20131209182619.GD6849@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131209182619.GD6849@sergelap>
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
Cc: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 12/10/2013 02:26 AM, Serge Hallyn wrote:
> Quoting Gao feng (gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
>> On 12/07/2013 06:12 AM, Serge E. Hallyn wrote:
>>> Quoting Gao feng (gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
>>>> Hi
>>>>
>>>> On 10/24/2013 03:31 PM, Gao feng wrote:
>>>>> Here is the v1 patchset: http://lwn.net/Articles/549546/
>>>>>
>>>>> The main target of this patchset is allowing user in audit
>>>>> namespace to generate the USER_MSG type of audit message,
>>>>> some userspace tools need to generate audit message, or
>>>>> these tools will broken.
>>>>>
>>>>
>>>> I really need this feature, right now,some process such as
>>>> logind are broken in container becase we leak of this feature.
>>>
>>> Your set doesn't address loginuid though right?  How exactly do you
>>> expect to do that?  If user violates MAC policy and audit msg is
>>> sent to init user ns by mac subsys, you need the loginuid from
>>> init_audit_ns.  where will that be stored if you allow updates
>>> of loginuid in auditns?
>>>
>> This patchset doesn't include the loginuid part.
>>
>> the loginuid is stored in task as before.
>> In my opinion, when task creates a new audit namespace, this task's
>> loginuid will be reset to zero, so the children tasks can set their
>> loginuid. Does this change break the MAC?
> 
> I think so, yes.  In an LSPP selinux environment, if the task
> manages to trigger an selinux deny rule which is audited, then
> the loginuid must make sense on the host.  Now presumably it
> will get translated to the mapped host uid, and we can figure
> out the host uid owning it through /etc/subuid.  But that adds
> /etc/subuid as a new part of the TCB without any warning <shrug>
> So in that sense, for LSPP, it breaks it.
> 

Looks like my opinion is incorrect.

In the audit-next tree, Eric added a new audit feature to allow privileged
user to disable AUDIT_LOGINUID_IMMUTABLE. after AUDIT_LOGINUID_IMMUTABLE
is disabled, the privileged user can reset/set the loginuid of task. I
think this way is safe since only privileged user can do the change.

So I will not change the loginuid part.

Thanks for your information Serge :)
