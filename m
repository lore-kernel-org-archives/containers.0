From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH net-next 09/17] net: Allow userns root control of the core
	of the network stack.
Date: Fri, 16 Nov 2012 06:32:21 -0800
Message-ID: <871uft8vpm.fsf__4784.43660908869$1353076376$gmane$org@xmission.com>
References: <87d2zd8zwn.fsf@xmission.com>
	<1353070992-5552-1-git-send-email-ebiederm@xmission.com>
	<1353070992-5552-9-git-send-email-ebiederm@xmission.com>
	<50A645C2.1000604@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <50A645C2.1000604-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> (Glauber Costa's message of
	"Fri, 16 Nov 2012 17:55:14 +0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:

> On 11/16/2012 05:03 PM, Eric W. Biederman wrote:
>> +	if (!capable(CAP_NET_ADMIN))
>> +		return -EPERM;
>> +
>>  	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
>
> You mean ns_capable here?

No.  There I meant capable.

I deliberately call capable here because I don't understand what
the tx_queue_len well enough to be certain it is safe to relax
that check to be just ns_capable.

My get feel is that allowing an unprivileged user to be able to
arbitrarily change the tx_queue_len on a networking device would be a
nice way to allow queuing as many network packets as you would like with
kernel memory and DOSing the machine.

So since with a quick read of the code I could not convince myself it
was safe to allow unprivilged users to change tx_queue_len I left it
protected by capable.  While at the same time I relaxed the check in
netdev_store to be ns_capable.

Eric
