From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][PATCH 0/6] Enable multiple mounts of devpts
Date: Mon, 04 Aug 2008 19:07:24 -0700
Message-ID: <4897B5DC.10502@zytor.com>
References: <20080805011844.GA14940@us.ibm.com> <4897AECE.9060307@zytor.com>
	<20080805015334.GA16114@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080805015334.GA16114-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> 
> Ok. But was wondering if we can pass the ptmx symlink burden to the
> 'container-startup sripts' since they are the ones that need the second
> or subsequent mount of devpts.
> 
> So, initially and for systems that don't need multiple mounts of devpts,
> existing behavior can continue (/dev/ptmx is a node).
> 
> Container startup scripts have to anyway remount /dev/pts and mknod
> /dev/pts/ptmx. These scripts could additionally check if /dev/ptmx is
> a node and make it a symlink. The container script would have to do
> this check while it still has access to the first mount of devpts
> and mknod in the first devpts mnt.
> 
> But then again, the first mount is still special in the kernel.
> 

You're right, I think we can do this and still retain most of the 
advantages, at least for a transition period.

The idea would be that you'd have a mount option, that if you do not 
specify it, you get a bind to the in-kernel mount; otherwise you get a 
new instance.  ptmx, if not invoked from inside a devpts filesystem, 
would default to the kernel-mounted instance.

Unfortunately I believe that means parsing the command options in 
getpts_get_sb() to know if we do have the "multi" option, but that isn't 
really all that difficult; it just means breaking the parser out as a 
separate subroutine.

	-hpa
