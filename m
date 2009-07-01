From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [lxc-devel] segfault on shutdown if containers running
Date: Wed, 01 Jul 2009 10:14:47 +0200
Message-ID: <4A4B1AF7.8090009@fr.ibm.com>
References: <4A42D033.5060202@zombino.com> <4A432714.4040606@free.fr>
	<4A480F08.3040102@zombino.com> <4A48555E.9060607@free.fr>
	<4A491745.2050002@zombino.com> <4A491FDA.1050904@fr.ibm.com>
	<4A4AA6D6.2090308@zombino.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A4AA6D6.2090308-+878OnfSgr5BDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Adam Majer <adamm-+878OnfSgr5BDgjK7y7TUQ@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Adam Majer wrote:
>>>>> chrdev_open + 0x148/0x167
>>>>> chrdev_open + 0x0/0x167
>>>>> __dentry_open + 0x148/0x260
>>>>> do_flip_open + 0x468/0x85a
>>>>> alloc_fd + ....
>>>>> do_sys_gen + ...
>>>>> system_call_fastpath + ....
>>>>>
>>>>> RIP tty_open
>>>> which kernel are you using ? could you run :
>>>>
>>>>     $ addr2line -e <vmlinux> ffffffff803b26f1
> 
>>> Would setting this to yes produce a backtrace with line numbers?
>> Yes and maybe CONFIG_FRAME_POINTER too.
> 
> Well, adding symbols didn't add line numbers to the backtrace. But now I
> can use addr2line with the vmlinux (all 78mb of it) to get you guys a
> backtrace with line numbers :)
> 
> 
> So,
> 
> OOPS (NULL pointer deference) at
> 
>   drivers/char/tty_io.c:1321  (tty_open)
> 
> Backtrace,
> 
>   fs/char_dev.c:397 (chrdev_open)
>   fs/char_dev.c:357 (chrdev_open)
>   fs/open.c:841     (__dentry_open)
>   arch/x86/include/asm/atomic_64.h:117 (do_flip_open)
>   fs/file.c:459     (alloc_fd)
>   ...

Excellent !

Suka ? Isn't this oops related to the newpts instance ?

Thanks
   -- Daniel
