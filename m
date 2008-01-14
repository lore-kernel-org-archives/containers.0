From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Namespaces exhausted CLONE_XXX bits problem
Date: Mon, 14 Jan 2008 16:45:08 +0300
Message-ID: <478B6764.6050300@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi, guys!

I started looking at PTYs/TTYs/Console to make the appropriate
namespace and suddenly remembered that we have already
exhausted all the CLONE_ bits in 32-bit mask.

So, I recalled the discussions we had and saw the following 
proposals of how to track this problem (with their disadvantages):

1. make the clone2 system call with 64-bit mask
   - this is a new system call
2. re-use CLONE_STOPPED
   - this will give us only one bit
3. merge existing bits into one
   - we lose the ability to create them separately
4. implement a sys_unshare_ns system call with 64bit/arbitrary mask
   - this is anew system call
   - this will bring some dissymmetry between namespaces
5. use sys_indirect
   - this one is not in even -mm tree yet and it's questionable
     whether it will be at all

I have one more suggestion:

6. re-use bits, that don't make sense in sys_unshare (e.g.
   CLONE_STOPPED, CLONE_PARENT_SETTID, CLONE_VFORK etc)
   This will give us ~16 new bits, but this will look not very nice.

What do you think about all of this?

Thanks,
Pavel
