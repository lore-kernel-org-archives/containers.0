From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH 0/8][v2]: Enable multiple mounts of devpts
Date: Wed, 03 Sep 2008 06:12:06 -0700
Message-ID: <m1vdxdbcgp.fsf@frodo.ebiederm.org>
References: <20080821031028.GB30205@us.ibm.com> <48ACDDC7.3000704@zytor.com>
	<48AD991F.9010906@fr.ibm.com> <48AD9A97.6000807@zytor.com>
	<48AD9DCD.3060306@fr.ibm.com> <m1fxoys1ng.fsf@frodo.ebiederm.org>
	<48ADD7D3.7080400@fr.ibm.com> <48B7BB3C.5080404@fr.ibm.com>
	<20080902030426.GB12277@us.ibm.com>
	<m1vdxeeuk0.fsf@frodo.ebiederm.org> <20080902155211.GF8524@us.ibm.com>
	<48BE7C98.1040004@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48BE7C98.1040004-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> (Cedric Le Goater's message of
	"Wed, 03 Sep 2008 14:01:28 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, Dave Hansen <dave-gkUM19QKKo4@public.gmane.org>, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:

> ok. complete isolation would require 2 steps. I guess this is
> acceptable because mq uses a fs
>
> allowing the host to see the child's /dev/mqueue is also 'a nice 
> to have' feature. unfortunately, we can't do that for all namespaces,
> for sysvipc for example. So I'm wondering if we should allow it
> at all ?

Definitely.

One of the lessons from the people doing monitoring is that it really
is best done through a filesystem interface.  You don't have
to have it mounted and there are times you don't want to be able
to mount a view into another namespace but having the option is nice.

I'm torn because the more I look at the way posix message queues are
implemented the more it looks like new versions of sys_open and
sys_unlink should never have been written and it should have been a
user space convention to always mount mqueuefs on /dev/mqueue.

Just doing newinstance and having a pointer in nsproxy will get the
job done, but it feels like we may have the opportunity to correct a
blunder in the initial implementation.

Eric
