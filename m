From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: Pid namespaces problems
Date: Wed, 07 Nov 2007 09:28:29 +0100
Message-ID: <4731772D.3060806@fr.ibm.com>
References: <472AE42F.5000602@openvz.org>	<m1640id57r.fsf@ebiederm.dsl.xmission.com>
	<47301A14.9040304@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47301A14.9040304-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

> 
>> - There are several architectures with their own signal functions for
>>   other OS compatibility that have are using _pid and not _vpid
>>   variants of functions. (irix and solaris)
>>   arch/mips/kernel/irixsig.c:irix_waitsys
>>   arch/mips/kernel/sysirix.c:irix_setpgrp
>>   arch/sparc64/solaris/misc.c:solaris_procids
> 
> Ok. Looks like your list is the same as mine. That's good to hear
> that I haven't missed anything important.

We've also talked about af_unix credentials.

> So, I see that you're about to take a closer look at the pid
> namespaces. If so, then what time can we expect the net namespace
> activity to go on? Or (if you don't mind) can we start merging
> the patches to David as soon as he opens his 2.6.25 merge window?

I think daniel and benjamin are also getting ready for the 2.6.25 
merge window.

C.
