From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] C/R: Support for IPv6 addresses on network devices
	(v2)
Date: Wed, 07 Apr 2010 07:02:15 -0700
Message-ID: <87aatfbbtk.fsf@caffeine.danplanet.com>
References: <1270563183-9351-1-git-send-email-danms@us.ibm.com>
	<1270563183-9351-2-git-send-email-danms@us.ibm.com>
	<20100407041858.GA12287@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100407041858.GA12287-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Tue\, 6 Apr 2010 23\:18\:58 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

SH> 1. this will only trigger if CONFIG_IPV6=y, not if it =m.  So you
SH> might have meant
SH> 	#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)

Ah, okay, right.

>> +	addrs = ckpt_netdev_inet6_addrs(dev->ip6_ptr, addrs, max, abuf);
>> +	if (addrs == -E2BIG) {
>> +		read_unlock(&dev_base_lock);
>> +		goto retry;
>> +	}

SH> This is the second problem.  If CONFIG_IPV6=n or CONFIG_IPV6=m, then
SH> ckpt_netdev_inet6_addrs() will return -ENOSYS, and you'll fail here.
SH> So in those cases there is now no way to do a checkpoint with
SH> CHECKPOINT_NETNS (or without CHECKPOINT_NONETNS :).

SH> The fix of course can't be quite as simple as ignoring return
SH> value of -ENOSYS since you'll have lost the passed-in addrs from
SH> ckpt_netdev_inet4_addrs.

If I change it to compile in with CONFIG_IPV6_MODULE as you stated
above, then it won't return -ENOSYS, right?  The code will still be
there, and will not traverse the ipv6 address list (if I make it check
for an empty dev->ip6_ptr) until the module is loaded and the devices
gain some IPv6 information.

I'll test this and resend the patch appropriately.

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
