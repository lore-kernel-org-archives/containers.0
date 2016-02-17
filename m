From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] Make core_pattern support namespace
Date: Wed, 17 Feb 2016 14:15:24 -0600
Message-ID: <87k2m33xgj.fsf@x220.int.ebiederm.org>
References: <ce9a21e42a846150a2a482278f5b5a5e0ea27839.1454588184.git.zhaolei@cn.fujitsu.com>
	<20160216142608.GA16757@mguzik>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160216142608.GA16757@mguzik> (Mateusz Guzik's message of "Tue,
	16 Feb 2016 15:26:09 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Tue, Feb 16, 2016 at 07:33:39PM +0800, Zhao Lei wrote:
>> Currently, each container shared one copy of coredump setting
>> with the host system, if host system changed the setting, each
>> running containers will be affected.
>> 
>> Moreover, it is not easy to let each container keeping their own
>> coredump setting.
>> 
>> We can use some workaround as pipe program to make the second
>> requirement possible, but it is not simple, and both host and
>> container are limited to set to fixed pipe program.
>> In one word, for host running contailer, we can't change core_pattern
>> anymore.
>> To make the problem more hard, if a host running more than one
>> container product, each product will try to snatch the global
>> coredump setting to fit their own requirement.
>> 
>> For container based on namespace design, it is good to allow
>> each container keeping their own coredump setting.
>> 
>> It will bring us following benefit:
>> 1: Each container can change their own coredump setting
>>    based on operation on /proc/sys/kernel/core_pattern
>> 2: Coredump setting changed in host will not affect
>>    running containers.
>> 3: Support both case of "putting coredump in guest" and
>>    "putting curedump in host".
>> 
>> Each namespace-based software(lxc, docker, ..) can use this function
>> to custom their dump setting.
>> 
>> And this function makes each continer working as separate system,
>> it fit for design goal of namespace.
>> 
>
> Sorry if this is a false alarm, I don't have easy means to test it, but
> is not this an immediate privilege escalation?

It is.  This is why we do not currently have a per namespace setting.

Solving the user mode helper problem is technically a fair amount of
work, if not theoretically challenging.

Eric
