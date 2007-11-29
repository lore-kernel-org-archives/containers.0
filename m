From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch -mm 2/4] mqueue namespace : add unshare support
Date: Thu, 29 Nov 2007 11:28:28 +0100
Message-ID: <474E944C.4020809@fr.ibm.com>
References: <20071128163728.177495768@fr.ibm.com>>
	<20071128164349.196734045@fr.ibm.com>>
	<474DA61B.5030301@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <474DA61B.5030301-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

>> Index: 2.6.24-rc3-mm2/include/linux/sched.h
>> ===================================================================
>> --- 2.6.24-rc3-mm2.orig/include/linux/sched.h
>> +++ 2.6.24-rc3-mm2/include/linux/sched.h
>> @@ -27,6 +27,7 @@
>>  #define CLONE_NEWUSER		0x10000000	/* New user namespace */
>>  #define CLONE_NEWPID		0x20000000	/* New pid namespace */
>>  #define CLONE_NEWNET		0x40000000	/* New network namespace */
>> +#define CLONE_NEWMQ		0x80000000	/* New posix mqueue namespace */
> 
> That's it :) We've run out of clone flags on 32-bit platforms :(

yes. 

I have been giving some thoughts to a clone2() to extend the flags but
andrew is preparing to recycle CLONE_DETACHED and CLONE_STOPPED for
2.6.26. Some we might have some more time in front of us.

C.
