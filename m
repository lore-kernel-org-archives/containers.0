From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][PATCH 7/8]: Auto-create ptmx node when mounting devpts
Date: Thu, 21 Aug 2008 09:09:19 -0700
Message-ID: <48AD932F.8090908@zytor.com>
References: <20080821022126.GA29449@us.ibm.com>	<20080821022908.GG29658@us.ibm.com>
	<20080821102139.43c44f67@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080821102139.43c44f67-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Alan Cox wrote:
>> This patch has the kernel internally create the [ptmx, c, 5:2] device
>> when mounting devpts filesystem. The permissions for the device node
>> can be specified by the '-o ptmx_mode=0666' option. The default mode
>> is 0666.
> 
> NAK
> 
>> 	Hopefully, presence of the 'ptmx' node in /dev/pts does not surprise
>> 	user space.
> 
> If you are going to make major changes requiring user space changes to
> use them then you can change the user space rather than playing "gee
> where did that come from" with the existing system.
> 

This particular one I think is the right thing, despite everything.  In 
particular, it makes a *hell* of a lot more sense to have this 
auto-created, than supporting mknod(2) inside the devpts filesystem. 
It's not a matter of "changing the user space"; it's a matter of what 
makes most sense inside the kernel.

His new implementation doesn't require user space changes unless you 
want to take advantages of the multi-instance features.  It thus allows 
for a soft transition.  However, soft or hard transition is irrelevant 
-- creating ptmx inside devpts is necessary, and it doesn't make sense 
to require userspace to mknod it, since the kernel code ends up being 
more complex.

	-hpa
