From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [PATCH 11/11][v3]: Enable multiple instances of devpts
Date: Thu, 4 Sep 2008 19:01:31 -0700
Message-ID: <20080905020131.GA17535@us.ibm.com>
References: <20080904052718.GA3680@us.ibm.com>
	<20080904053551.GL3680@us.ibm.com> <48BF8283.7040601@zytor.com>
	<20080904155431.GA11174@us.ibm.com> <48C00698.8050803@zytor.com>
	<20080904172542.3ad7bb85@lxorguk.ukuu.org.uk>
	<48C01163.1050704@zytor.com> <20080904171828.GC11174@us.ibm.com>
	<48C01B58.2040006@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48C01B58.2040006-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
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
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

H. Peter Anvin [hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org] wrote:
> sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
>> But that node will not be accessible if there is a newinstance mount
>> without the bind mount ? IOW
>> 	1. mount -t devpts -o newinstance lxcpts /dev/pts
>> 	2. mount -o bind /dev/pts/ptmx /dev/ptmx
>> If both #1 and #2 or neither happen there is no problem.
>> If #1 is NOT followed by #2, ptys break in new namespace.
>> An open of /dev/ptmx in this case will allocate a pty in the
>> initial namespace, but since #1 is complete, we lookup the
>> pty (/dev/pts/7) in the new namespace and fail.
>
> That is correct.

So afaics, we don't have any issues when operating only in one mode
(single-instance or multi-instance).

When both modes are used simultaneously, we have following options:

1. Let container-startup deal with it i.e use above bind-mount approach
   or, as Serge mentioned, have containers chroot and make ptmx->pts/ptmx
   symlink or another option ?

2. Have the ptmx-node even in the initial mount and a "permanent" ptmx
   symlink -  Did we fully rule it out :-)

3. Choose #2 with a (yet-another) config token. Not sure if it adds
   value or further complicates the matrix.

Both #1 and #2 have their pros/cons.  Long term, one advantage I see with #2
is that we don't force container-scripts do something now that they can/should
potentially undo later if we ever want to remove the single-instance semantics.

Does presence of /dev/pts/ptmx in single-instance case break userspace ?
If it only surprises, will adding notes to pts(4) man page help ?

Or are there other options ?

Thanks,

Suka
