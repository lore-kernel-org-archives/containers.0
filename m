From: Prashanth Mohan <prashmohan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Unable to checkpoint containers
Date: Wed, 13 Jul 2011 15:26:37 -0700
Message-ID: <CAC6a4awwhzHNKz3y0UAQbnjLPvwRfXv7ZKj625i_RUbnmcu2Gw@mail.gmail.com>
References: <CAC6a4axWVio4f7-v37NR+66-ZG9NHToaSGt6rT3d1jVHS0gfcA@mail.gmail.com>
	<1310549994.11339.21.camel@bahia.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1310549994.11339.21.camel-GiB8zCg7hOfDOqzlkpFKJg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jul 13, 2011 at 2:39 AM, Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> wrote:
> On Wed, 2011-07-13 at 01:22 -0700, Prashanth Mohan wrote:
>> Hello,
>>
>> I have been following the steps in
>> https://ckpt.wiki.kernel.org/index.php/Link-LXC-USERCR to get the LXC
>> 0.7.1 stack to work with checkpoint and restore functionality. When I
>> try to checkpoint a container, I get the following error (prmohan6
>> being my container name):
>>
>> lxc-checkpoint: checkpoint of prmohan6 (pid 8263) failed
>>
>> lxc-checkpoint: failed to checkpoint 'prmohan6'
>>
> Hi,
>
> AFAIK, these patchsets for LXC are experimental and unmaintained...


I realize this. But the wiki seemed to indicate that there was at
least a partially working build available that I might be able to
develop on top of.

> Did you freeze the container before checkpointing ?

I had not done that. I just tried it now, and it still gives me the same error.

-- 
Prashanth Mohan
http://www.cs.berkeley.edu/~prmohan
