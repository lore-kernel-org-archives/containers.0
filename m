From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v5 0/4] cgroup notifications API and memory thresholds
Date: Mon, 4 Jan 2010 06:06:12 +0530
Message-ID: <20100104003612.GF16187__25861.7485793822$1262565468$gmane$org@balbir.in.ibm.com>
References: <cover.1262186097.git.kirill@shutemov.name>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1262186097.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: Alexander Shishkin <virtuoso-0lOfPCoBze7YtjvyW6yDsg@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

* Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> [2009-12-30 17:57:55]:

> This patchset introduces eventfd-based API for notifications in cgroups and
> implements memory notifications on top of it.
> 
> It uses statistics in memory controler to track memory usage.
> 
> Output of time(1) on building kernel on tmpfs:
> 
> Root cgroup before changes:
> 	make -j2  506.37 user 60.93s system 193% cpu 4:52.77 total
> Non-root cgroup before changes:
> 	make -j2  507.14 user 62.66s system 193% cpu 4:54.74 total
> Root cgroup after changes (0 thresholds):
> 	make -j2  507.13 user 62.20s system 193% cpu 4:53.55 total
> Non-root cgroup after changes (0 thresholds):
> 	make -j2  507.70 user 64.20s system 193% cpu 4:55.70 total
> Root cgroup after changes (1 thresholds, never crossed):
> 	make -j2  506.97 user 62.20s system 193% cpu 4:53.90 total
> Non-root cgroup after changes (1 thresholds, never crossed):
> 	make -j2  507.55 user 64.08s system 193% cpu 4:55.63 total
> 
> Any comments?

Hi,

I just saw that the notification work for me using the tool you
supplied. One strange thing was that I got notified even though
the amount of data I was using was reducing, so I hit the notification
two ways

        +------------+-----------
                    1G
                ----> (got notified on increase)
                <---- (got notified on decrease)

I am not against the behaviour, but it can be confusing unless
clarified with the event.

-- 
	Balbir
