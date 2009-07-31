From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Fri, 31 Jul 2009 23:58:42 +0200
Message-ID: <1249077522.9378.95.camel@eskarina>
References: <20090719071531.GA20818@megiteam.pl>
	<20090722064120.GA24373@us.ibm.com> <20090722222550.GA633@megiteam.pl>
	<20090723012733.GB27764@us.ibm.com> <4A67C187.5000201@zytor.com>
	<20090723182620.GA16322@megiteam.pl>
	<20090723193245.GA25662@us.ibm.com>
	<20090723203329.GC16322@megiteam.pl> <4A68E026.1070608@zytor.com>
	<20090724073158.GA2617@megiteam.pl> <20090730180611.GA20872@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090730180611.GA20872-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

Dnia 2009-07-30, czw o godzinie 11:06 -0700, Sukadev Bhattiprolu pisze:
> Well, I made some progress on this. In an earlier mail you mentioned
> that your test case "survives" in kernels without the bad commit.
> 
> With the following patch the kernel seems to _survive_ but not sure if
> "surviving" meets your real needs (i.e does the pty continue to function
> as the console for the container) ? 

Both my patch and yours make the console open fail and I'm not sure we
can do much better. I don't think this matters (too much) either as the
supervisor (libvirt_lxc) exits only on container shutdown, so there's
nothing much we can do to the container anyway.

During normal operation the console works just like before. However,
(but this is not related to the patch at all) I can't get it to work
predictably, let alone usefully (mounting the console from the libvirtd
config file silently fails, leaving the console at major:minor 5:1 and
messing with the host's console; mounting it from inside the container
apparently races with something and sometimes fails with /dev/pts/0
missing and anyway exposes the host's console to init). Will see
tomorrow.

> The way I understand, the child process does not get an open-file reference
> to the pty. So when the parent closes the pty, devpts_pty_kill() unhashes
> the dentry (although the bind mount() in the child has a reference count
> on dentry).

Sounds plausible and your patch communicates the idea quite clearly.

Best regards,
 Grzegorz Nosek
