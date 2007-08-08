From: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Subject: Re: netns34
Date: Wed, 08 Aug 2007 13:16:48 +0200
Message-ID: <46B9A620.4050906@bull.net>
References: <m11wefgfl0.fsf@ebiederm.dsl.xmission.com>
	<m1wsw7f0r0.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070604070307010001030809"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1wsw7f0r0.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-juSfH4iHXoxBDgjK7y7TUQ@public.gmane.org>, "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------070604070307010001030809
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed

Hi Eric,

I've cloned the repository and built the kernel.

Unshare support is broken. It misses a small change in sys_unshare()
to accept the CLONE_NEWNET flag.
I guess it should be added in commit "net: Add network namespace
clone & unshare support." (See attached patch below)

Also, have you removed the "sysfs interface support for moving devices 
between namespaces" on purpose?
Is there another way to move interfaces now?

Benjamin

Eric W. Biederman wrote:
> ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:
> 
>> Ok.  After a bunch of work I have my network namespace patches working
>> again against 2.6.23-rc2 or whatever is linus's latest.
>>
>> I need to break out my sysctl work and send that separately.
>>
>> I need to get veth in there and I need to get a patch to /sbin/ip
>> to work with Patrick McHardy's form of patches.
>>
>> But I think I am quickly approaching the point where I will have
>> patches ready for merging.
>>
>> Once I get sysctl sorted out I will start post a minimal patchset
>> for prereview and see where things go.
>>
>> Hopefully my sysfs work finally sticks this time.
> 
> And the important part the code will shortly be available at:
> git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/linux-2.6-netns.git#netns/v2.6.23-rc2netns34
> 
> And also from the default head.
> 
> Eric
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com

--------------070604070307010001030809
Content-Transfer-Encoding: 7bit
Content-Type: text/x-patch;
 name="Fix-netns-unshare-support.patch"
Content-Disposition: inline;
 filename="Fix-netns-unshare-support.patch"

Fix network namespace unshare support.
Add CLONE_NEWNET flag in sys_unshare().

Index: linux-2.6.23-rc2-netns34/kernel/fork.c
===================================================================
--- linux-2.6.23-rc2-netns34.orig/kernel/fork.c
+++ linux-2.6.23-rc2-netns34/kernel/fork.c
@@ -1608,7 +1608,8 @@ asmlinkage long sys_unshare(unsigned lon
 	err = -EINVAL;
 	if (unshare_flags & ~(CLONE_THREAD|CLONE_FS|CLONE_NEWNS|CLONE_SIGHAND|
 				CLONE_VM|CLONE_FILES|CLONE_SYSVSEM|
-				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWUSER))
+				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWUSER|
+				CLONE_NEWNET))
 		goto bad_unshare_out;
 
 	if ((err = unshare_thread(unshare_flags)))

--------------070604070307010001030809
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--------------070604070307010001030809--
