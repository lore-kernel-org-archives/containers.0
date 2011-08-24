From: Zan Lynx <zlynx-HInyCGIudOg@public.gmane.org>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Wed, 24 Aug 2011 09:05:21 -0600
Message-ID: <4E551331.1010709@acm.org>
References: <20110824085329.GL29452@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110824085329.GL29452@sun>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, LINUXFS-ML <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 8/24/2011 2:53 AM, Cyrill Gorcunov wrote:
> From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> 
> This one behaves similarly to the /proc/<pid>/fd/ one - it contains symlinks
> one for each mapping with file, the name of a symlink is vma->vm_start, the
> target is the file. Opening a symlink results in a file that point exactly
> to the same inode as them vma's one.
> 
> This thing is aimed to help checkpointing processes.
> 
> For example the ls -l of some arbitrary /proc/<pid>/map_files/
> 
>  | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73a00000 -> /lib64/ld-2.5.so
[snip]

Just curious: How do these symlinks work when the process reading a
/proc file is in a chroot or a different namespace?

For example, a chroot environment might have independent copies of
/lib64/ld-2.5.so and a bind mount of /proc. Does the symlink then point
to the wrong file?
