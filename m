From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [RFC][PATCH 0/6] Enable multiple mounts of devpts
Date: Mon, 4 Aug 2008 18:53:34 -0700
Message-ID: <20080805015334.GA16114@us.ibm.com>
References: <20080805011844.GA14940@us.ibm.com> <4897AECE.9060307@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4897AECE.9060307-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

H. Peter Anvin [hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org] wrote:
> sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
>> If devpts is mounted more than once, then '/dev/ptmx' must be a symlink
>> to '/dev/pts/ptmx' and in each new devpts mount we must create the
>> device node '/dev/pts/ptmx' [c, 5;2] by hand.
>
> This should be auto-created.  That also eliminates any need to support the 
> mknod system call.

Ok. But was wondering if we can pass the ptmx symlink burden to the
'container-startup sripts' since they are the ones that need the second
or subsequent mount of devpts.

So, initially and for systems that don't need multiple mounts of devpts,
existing behavior can continue (/dev/ptmx is a node).

Container startup scripts have to anyway remount /dev/pts and mknod
/dev/pts/ptmx. These scripts could additionally check if /dev/ptmx is
a node and make it a symlink. The container script would have to do
this check while it still has access to the first mount of devpts
and mknod in the first devpts mnt.

But then again, the first mount is still special in the kernel.

>
>> Appreciate comments on overall approach of my mapping from the inode
>> to sb->s_fs_info to allocated_ptys and the hacky use of get_sb_nodev(),
>> and also on the tweak to init_dev() (patch 6).
>> Todo:
>> 	User-space impact of /dev/ptmx symlink - Options are being
>> 	discussed on mailing list (new mount option and config token,
>> 	new fs name, etc)
>> 	Remove even initial kernel mount of devpts ?
>
> The initial kernel mount of devpts should be removed, since that instance 
> will never be accessible.
>
> 	-hpa
