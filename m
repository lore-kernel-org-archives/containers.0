From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [PATCH 11/11][v3]: Enable multiple instances of devpts
Date: Sat, 6 Sep 2008 14:45:56 -0700
Message-ID: <20080906214556.GA27373@us.ibm.com>
References: <48C00698.8050803@zytor.com>
	<20080904172542.3ad7bb85@lxorguk.ukuu.org.uk>
	<48C01163.1050704@zytor.com> <20080904171828.GC11174@us.ibm.com>
	<48C01B58.2040006@zytor.com> <20080905020131.GA17535@us.ibm.com>
	<20080905132710.50018aef@lxorguk.ukuu.org.uk>
	<48C16B42.7030103@zytor.com> <20080905194450.GA18119@us.ibm.com>
	<48C28E3D.6060404@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48C28E3D.6060404-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
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
>> Agree in general. Not sure if you are implying remount is necessary just
>> to change permissions of pts/ptmx. Why not "chmod 0666 /dev/pts/ptmx" ?
>> The remount changes the 'ptmxmode' setting, but since the node exists,
>> the 'ptmxmode' setting is never used again and we need to chmod.
>
> A chmod requires bigger changes to existing scripts than an option which 
> can be set in /etc/fstab.

Ok. From implementation pov, we can cache the ptmx dentry in s_fs_info
and use it during remount to change the permissions. We could lookup
ptmx during remount, but caching is simpler ?

>
>> ptmx node in multi-instance mounts continue to get PTMX_DEFAULT_MODE
>> permissions (not 000) right ? (unless -o ptmxmode is specified)
>
> It's probably easier to always default it to zero and expect that the mode 
> is set explicitly.

Ok.

BTW, I have added CONFIG_DEVPTS_MULTIPLE_INSTANCES and moved the usage
info from 11/11 to Documentation/fs/devpts.txt.

Will make above ptmx changes, port to recent ttydev tree and send updated
patchset in a couple of days.

Thanks,

suka
