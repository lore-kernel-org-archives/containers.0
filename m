From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] audit: listen in all network namespaces
Date: Fri, 20 Dec 2013 11:45:56 +0800
Message-ID: <52B3BD74.7040204@cn.fujitsu.com>
References: <1374006760-7687-1-git-send-email-rgb@redhat.com>		
	<52B26F1A.9070308@cn.fujitsu.com>	
	<1387478422.29366.33.camel@flatline.rdu.redhat.com>	
	<52B3AF8F.5040607@cn.fujitsu.com>
	<1387509074.2919.36.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1387509074.2919.36.camel@localhost>
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

On 12/20/2013 11:11 AM, Eric Paris wrote:
> On Fri, 2013-12-20 at 10:46 +0800, Gao feng wrote:
>> On 12/20/2013 02:40 AM, Eric Paris wrote:
>>> On Thu, 2013-12-19 at 11:59 +0800, Gao feng wrote:
>>>> On 07/17/2013 04:32 AM, Richard Guy Briggs wrote:
> 
>>>> we have to store audit_sock
>>>> into auditns(auditns will be passed to kauditd_send_skb),
>>>> this will cause auditns have to get a reference of netns.
>>>> and for some reason(netfilter audit target), netns will
>>>> get reference of auditns too. this is terrible...
>>>
>>> I'm not sure I agree/understand this entirely...
>>>
>>
>> Yes, the audit_sock is created and destroyed by net namespace,
>> so if auditns wants to use audit_sock, it must prevent netns
>> from being destroyed. so auditns has to get reference of netns.
> 
> Namespace == mind blown.  Ok, so:
> 
>  auditd in audit_ns2 and net_ns2. <--- ONLY process in net_ns2
>  some process in audit_ns2 and net_ns3
> 
> Lets assume that auditd is killed improperly/dies.  Because the last
> process in net_ns2 is gone net_ns2 is invalid/freed.
> 
> Today in the kernel the way we detect auditd is gone is by using the
> socket and getting ECONNREFUSSED.  So here you think that audit_ns2
> should hold a reference on net_ns2, to make sure that socket is always
> valid.
> 
> I instead propose that we could run all audit_ns and reset the audit_pid
> in that namespace and the audit_sock in the namespace to 0/null inside
> audit_net_exit.  Since obviously if the net_ns disappeared, the auditd
> which was running in any audit namespace in that net_ns isn't running
> any more.  We didn't need to hold a reference on the net_ns.  We just
> have to clear the skb_queue, reset the audit_pid to 0, and reset the
> socket to NULL...

multi auditns can share the same netns. it happens if you unshare
auditns. if you want to reset audit_sock to null inside audit_net_exit,
you have to maintain a list in netns, this list contains the auditnss
whose audit_sock is created in this netns. so you can foreach this
list and reset the audit socks of audit nss.

Above is unsharing auditns, consider unsharing netns. auditd is running
in auditns1 and netns1, and then who-know-why the auditd call unshare(CLONE_NEWNET)
to change it's netns from netns1 to new netns2. so the netns1 is released
and auditns->audit_sock being reset to NULL. the auditd cannot receive
the audit log. auditd will in chaos, "I'm still alive, why kernel think
I'm die?"

So maybe you will say, we can reset the audit_sock of netns2 to auditns.
ok, this is a way. but how can we decide if we should reset the auditns->audit_sock?
when we create the new netns, the old netns is still alive, so the auditns->audit_sock
is still valid in that time.

I don't know if there are some other problems we should consider.
it is too complex..

> 
> Maybe the one magic socket is the right answer.  I'm not arguing against
> your solution.  I'm really trying to understand why we are going that
> way...
> 

That's why we should discuss :)
