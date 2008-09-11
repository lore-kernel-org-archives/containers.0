From: "xiaoming.zhang" <zxm927-9Onoh4P/yGk@public.gmane.org>
Subject: Re: sysfs question
Date: Thu, 11 Sep 2008 23:53:46 +0800
Message-ID: <200809112353.47144.zxm927@163.com>
References: <dac45060809110701i49acb8e7m7d8e3ccea7c59ab7@mail.gmail.com>
	<200809112226.59518.zxm927@163.com> <48C93B3D.3050303@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48C93B3D.3050303-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thursday 11 September 2008 11:37:33 pm Daniel Lezcano wrote:
> xiaoming.zhang wrote:
> > On Thursday 11 September 2008 10:05:43 pm Mark Ryden wrote:
> >> In fact, after looking more closely, I see that before that message
> >> appears: Error: unmouting old /sys
> >> ERROR unmounting old /sys: Invalid argument.
> >> forcing unmount of /sys
> >> switchroot...
> >
> > My experience is you'd better to find a sysfs patch, since the sysfs
> > filesystem is required by ramdisk and some system utilities, e.g., system
> > network configuration scripts.
> >
> > Patch for mm-tree can be found here:
> > 	http://lxc.sourceforge.net/patches/2.6.26/
> >
> > This is what I used:
> > http://lxc.sourceforge.net/patches/2.6.26/2.6.26-rc8-mm1-lxc1/broken-out/
> >sysfs/
> >
> > I merged these 11 patches on Linux-2.6.26.1 though I don't understand
> > these patches, luckily enough it worked for me.
>
> As mentioned Benjamin, it is hard to boot a distro without sysfs. I
> think it is a good idea to use the lxc patchset.
>
> You can use the latest version:
>
> http://lxc.sourceforge.net/patches/2.6.27/2.6.27-rc6-lxc1/
>
Thank you very much. And is there any patchset for Linux-2.6.26.* (not the 
mm-tree)?


> If you want to play with the container, you have the userspace tools at:
>
> http://lxc.sourceforge.net/download/lxc/
>
> Don't forget to check the README in the directory ;)
>
>    -- Daniel



-- 
Have fun,
Xiaoming Zhang
