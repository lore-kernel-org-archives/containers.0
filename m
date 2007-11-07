From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: Pid namespaces problems
Date: Wed, 07 Nov 2007 19:12:14 +0300
Message-ID: <4731E3DE.6000501@openvz.org>
References: <472AE42F.5000602@openvz.org>	<m1640id57r.fsf@ebiederm.dsl.xmission.com>	<47301A14.9040304@openvz.org>
	<4731772D.3060806@fr.ibm.com> <47317EA7.6030500@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47317EA7.6030500-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

Daniel Lezcano wrote:
> Cedric Le Goater wrote:
>>>> - There are several architectures with their own signal functions for
>>>>   other OS compatibility that have are using _pid and not _vpid
>>>>   variants of functions. (irix and solaris)
>>>>   arch/mips/kernel/irixsig.c:irix_waitsys
>>>>   arch/mips/kernel/sysirix.c:irix_setpgrp
>>>>   arch/sparc64/solaris/misc.c:solaris_procids
>>> Ok. Looks like your list is the same as mine. That's good to hear
>>> that I haven't missed anything important.
>> We've also talked about af_unix credentials.
>>
>>> So, I see that you're about to take a closer look at the pid
>>> namespaces. If so, then what time can we expect the net namespace
>>> activity to go on? Or (if you don't mind) can we start merging
>>> the patches to David as soon as he opens his 2.6.25 merge window?
>> I think daniel and benjamin are also getting ready for the 2.6.25 
>> merge window.
> 
> Yes. It can be cool if we can sync up Benjamin, Pavel, Denis, Eric and I 
> with the different parts to be posted. 

Yup. Team work will give us a chance to get in to the 2.6.25 with
the core virtualization. By core I mean unix, netlinux, ipv4 and ipv6.

Netfilters virtualization is a complex task :)

> Benjamin and I we began to look 
> at ipv4. This is a big part, perhaps we can split that into several 
> subset and dispatch them, except if Pavel and Denis already rebase ipv4 
> for net-2.6, in this case feel free to send them out.

Well, actually we have almost moved to the net-2.6 with the ipv4
set. There are only some minor (I hope they are minor ;)) things.
So we would be glad to go on with ipv4 further. What's up with the
ipv6 patches, Daniel? You said that you and Benjamin make some
big progress in this area, no?

Thanks,
Pavel
