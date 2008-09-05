From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [PATCH 11/11][v3]: Enable multiple instances of devpts
Date: Fri, 5 Sep 2008 12:44:50 -0700
Message-ID: <20080905194450.GA18119@us.ibm.com>
References: <48BF8283.7040601@zytor.com> <20080904155431.GA11174@us.ibm.com>
	<48C00698.8050803@zytor.com>
	<20080904172542.3ad7bb85@lxorguk.ukuu.org.uk>
	<48C01163.1050704@zytor.com> <20080904171828.GC11174@us.ibm.com>
	<48C01B58.2040006@zytor.com> <20080905020131.GA17535@us.ibm.com>
	<20080905132710.50018aef@lxorguk.ukuu.org.uk>
	<48C16B42.7030103@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48C16B42.7030103-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
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
>>> Does presence of /dev/pts/ptmx in single-instance case break userspace ?
>> It changes the permssion rules and subverts any permissions and security
>> labels applied to the current node.
>> If it was there and defaulted to no permission I doubt anything would
>> care - ie presence is not the problem, rights management is.
>
> It would be easy enough to have it default to mode 000 unless otherwise 
> specified.  For the default instance it is important that a remount can 
> update the permissions (since the original mount will be the kernel 
> version), but that's pretty straightforward.

Agree in general. Not sure if you are implying remount is necessary just
to change permissions of pts/ptmx. Why not "chmod 0666 /dev/pts/ptmx" ?
The remount changes the 'ptmxmode' setting, but since the node exists,
the 'ptmxmode' setting is never used again and we need to chmod.

> That might be the best option?

For containers or multi-instance mode, I agree.

In mixed mode, one observation is if /dev/ptmx is changed to symlink, regular
(not container) startup scripts must chmod /dev/pts/ptmx on _every_ boot.

ptmx node in multi-instance mounts continue to get PTMX_DEFAULT_MODE
permissions (not 000) right ? (unless -o ptmxmode is specified)

Yes, I think its a good option.
