From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] audit: listen in all network namespaces
Date: Fri, 20 Dec 2013 10:46:39 +0800
Message-ID: <52B3AF8F.5040607@cn.fujitsu.com>
References: <1374006760-7687-1-git-send-email-rgb@redhat.com>	
	<52B26F1A.9070308@cn.fujitsu.com>
	<1387478422.29366.33.camel@flatline.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1387478422.29366.33.camel-OjZBOOqb7SR7cYLChsl7DafLeoKvNuZc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 12/20/2013 02:40 AM, Eric Paris wrote:
> On Thu, 2013-12-19 at 11:59 +0800, Gao feng wrote:
>> On 07/17/2013 04:32 AM, Richard Guy Briggs wrote:
>>> Convert audit from only listening in init_net to use register_pernet_subsys()
>>> to dynamically manage the netlink socket list.
>>>
>>> Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>> ---
>>
>> I think it's the time for us to discuss if we should revert this
>> commit, since this one prevent me from continuing to achieve
>> audit namespace.
>>
>>
>> The major problem is in kaudit_send_skb, we have no idea which
>> audit sock the skb should send to.
> 
> right, we have problems here no matter what...
> 
> If we stick with the current approach you will need to know socket +
> portid.  With your approach one only needs to know portid.  Since these
> are can both be part of the audit_ns structure I don't see a huge
> difference...
> 
>> we have to store audit_sock
>> into auditns(auditns will be passed to kauditd_send_skb),
>> this will cause auditns have to get a reference of netns.
>> and for some reason(netfilter audit target), netns will
>> get reference of auditns too. this is terrible...
> 
> I'm not sure I agree/understand this entirely...
> 

Yes, the audit_sock is created and destroyed by net namespace,
so if auditns wants to use audit_sock, it must prevent netns
from being destroyed. so auditns has to get reference of netns.

and in some case, netns will get reference of auditns too. this
is complex than making audit_sock global and getting rid of this
reference.
