From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 1/1] Memory usage limit notification addition to memcg
Date: Wed, 15 Jul 2009 11:32:52 +0530
Message-ID: <20090715060252.GI24034__12455.3309673958$1247637873$gmane$org@balbir.in.ibm.com>
References: <1239660512-25468-1-git-send-email-dan@embeddedalley.com>
	<1246998310-16764-1-git-send-email-vbuzov@embeddedalley.com>
	<1246998310-16764-2-git-send-email-vbuzov@embeddedalley.com>
	<20090708095616.cdfe8c7c.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830907131515h3c9622b5v309cf8f13d272bab@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830907131515h3c9622b5v309cf8f13d272bab-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers Mailing List <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
List-Id: containers.vger.kernel.org

* menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> [2009-07-13 15:15:45]:

> On Tue, Jul 7, 2009 at 5:56 PM, KAMEZAWA
> Hiroyuki<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> >
> > I know people likes to wait for file descriptor to get notification in these days.
> > Can't we have "event" file descriptor in cgroup layer and make it reusable for
> > other purposes ?
> 
> I agree - rather than having to add a separate "wait for value to
> cross X threshold" file for each numeric usage value that people might
> be concerned about, it would be better to have a generic way to do it
> for any file. Given that this is a userspace API, it would be better
> to work out at least the generic API first, even if the initial
> implementation isn't generic.
> 
> Properties that it should support include:
> 
> - notification when a value crosses above or below a given threshold
> (which would include binary cases such as OOM notification where the
> value cross from "not-OOM" to "OOM"
> 
> - independent thresholds for different waiters
> 
> - epoll support (by using eventfd?)
> 
> - automatic wakeup when a cgroup is removed
> 
> - maybe optional wakeup when a thread attach occurs?
>

Please don't forget netlink, we've already got a genetlink socket for
cgroups in the form og cgroupstats.
 
> - not require more than read permissions on the file containing the
> value being monitored
> 
> I guess there are a few possible ways this could be exposed to userspace:
> 
> 1) new ioctl on cgroups files. simple but probably not popular
> 
> 2) new system call. maybe the cleanest, but involves changing every
> arch and is hard to script
> 
> 3) new per-cgroup file to control these e.g:
>   - create an eventfd
>   - open the control file to be monitored
>   - write the "<event_fd>, <control_fd> <threshold> to
> cgroup.event_control to link them together
> flexible and scriptable but maybe a clumsy interface in general
> 
> Paul

-- 
	Balbir
