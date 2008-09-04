From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [PATCH 11/11][v3]: Enable multiple instances of devpts
Date: Thu, 4 Sep 2008 10:18:28 -0700
Message-ID: <20080904171828.GC11174@us.ibm.com>
References: <20080904052718.GA3680@us.ibm.com>
	<20080904053551.GL3680@us.ibm.com> <48BF8283.7040601@zytor.com>
	<20080904155431.GA11174@us.ibm.com> <48C00698.8050803@zytor.com>
	<20080904172542.3ad7bb85@lxorguk.ukuu.org.uk>
	<48C01163.1050704@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48C01163.1050704-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
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
> Alan Cox wrote:
>> O> We can't, really, because it will open the global ptmx.  This is an 
>>> unfortunate side effect of the backwards-compatibility code.
>>>
>>> This is also why I don't like the bind mount; the symlink option has the 
>>> nice property that f*ckups are more obvious.
>> It's asking for trouble with existing systems and users that
>> upgrade. /dev/ptmx should remain a proper device file for the non
>> container case.
>
> I did say that as being the desired *eventual* goal.
>
>> Should /dev/ptmx give you a node in the 'master' pty namespace or a node
>> in your current containers pty namespace ?
>
> Well, since there is no "current containers pty namespace" per se, it will 
> give you a node in the default (initial) pty namespace unless the bind
> mount is set up.

But that node will not be accessible if there is a newinstance mount
without the bind mount ? IOW

	1. mount -t devpts -o newinstance lxcpts /dev/pts
	2. mount -o bind /dev/pts/ptmx /dev/ptmx

If both #1 and #2 or neither happen there is no problem.

If #1 is NOT followed by #2, ptys break in new namespace.

An open of /dev/ptmx in this case will allocate a pty in the
initial namespace, but since #1 is complete, we lookup the
pty (/dev/pts/7) in the new namespace and fail.
