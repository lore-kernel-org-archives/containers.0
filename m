From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 0/4] cgroups: show correct file mode
Date: Tue, 3 Mar 2009 10:19:41 +0900
Message-ID: <20090303101941.8c2041b7.kamezawa.hiroyu__27064.6035824486$1236043442$gmane$org@jp.fujitsu.com>
References: <49AB40BF.4030706@cn.fujitsu.com>
	<6599ad830903021019p3b29c173oc7772af6679d90e0@mail.gmail.com>
	<49AC8307.7090008@cn.fujitsu.com>
	<20090303100827.43d82c3a.kamezawa.hiroyu@jp.fujitsu.com>
	<49AC84BE.5020501@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49AC84BE.5020501-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 03 Mar 2009 09:15:42 +0800
Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:

> >> +/**
> >> + * cgroup_file_mode - deduce file mode of a control file
> >> + * @cft: the control file in question
> >> + *
> >> + * returns cftype->mode if ->mode is not 0
> >> + * returns 0644 if it has both a read and a write handler
> >> + * returns 0444 if it has only a read handler
> >> + * returns 0200 if it has only a write hander
> >> + */
> >> +static int cgroup_file_mode(const struct cftype *cft)
> >> +{
> >> +	int mode = 0;
> >> +
> >> +	if (cft->mode)
> >> +		return cft->mode;
> >> +
> >> +	if (cft->read || cft->read_u64 || cft->read_s64 ||
> >> +	    cft->read_map || cft->read_seq_string)
> >> +		mode += 0444;
> >> +
> >> +	if (cft->write || cft->write_u64 || cft->write_s64 ||
> >> +	    cft->write_string || cft->trigger)
> >> +		mode += 0200;
> >> +
> > 
> > += is not |=...
> > 
> 
> Ah, yes, though both happen to result in 0644.
> 
yes but I like |= rather than += in bit ops.

Reviewed-by; KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
