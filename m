From: "Satoshi UCHIDA" <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Subject: RE: Loadable cgroup subsystems
Date: Wed, 9 Apr 2008 17:31:58 +0900
Message-ID: <00f201c89a1c$2d2e4cf0$878ae6d0$@jp.nec.com>
References: <1207633175.7798.5.camel@nikanth-laptop.blr.novell.com>	
	<1207647629.7798.40.camel@nikanth-laptop.blr.novell.com>
	<6599ad830804080241u68d68e2bo8739f907306571bd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830804080241u68d68e2bo8739f907306571bd-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: ja
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: 'Paul Menage' <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, 'Nikanth Karthikesan' <knikanth-l3A5Bk7waGM@public.gmane.org>
Cc: 'Vasily Tarasov' <vtaras-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

> >  There were some band-width control patches based on cfq + cgroups, which
> >  I guess will mandate cfq to be built-in?
> >
> 
> Yes, or else have built-in stubs for the cgroup subsystem that load
> cfq and the code that uses cfq the first time someone tries to mount
> that subsystem.
> 

I think that it is too early to decide which band-width control for
cgroups will　mandate to be built-in.
Before that, we need more discussion about a band-width control and
its　implementation.
I seems that both implementation are still prototype and immature.
Both implementation would have good points and bad points respectively.


If you want to manage these patchset by one source tree, we should
choice adopting means by a build option.
So, I think that a build option is the better at present, but I guess
that it should be better to dynamically load subsystem in future.

I have idea that handles multiple implementation as provisional solution.
Now, all bandwidth control expands CFQ original code and is valid by build options.
It is good to be re-implemented as new I/O scheduler which reuses original code.
Therefore, it became a selectable such as other I/O scheduler (anticipatory, cfq, noop, etc.)
User can select a suitable scheduler through "scheduler" entry in sysfs. 
In addition, it's possible to use a new controller simultaneously with existing I/O scheduler.
Unfortunately, this idea would require much modification to each patchset.

-----
Satoshi UCHIDA
