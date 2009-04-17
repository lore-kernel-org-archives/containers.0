From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 3/9] bio-cgroup controller
Date: Fri, 17 Apr 2009 11:24:33 +0900
Message-ID: <20090417112433.085ed604.kamezawa.hiroyu__46079.6621664942$1239935343$gmane$org@jp.fujitsu.com>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
	<1239740480-28125-4-git-send-email-righi.andrea@gmail.com>
	<49E7E037.9080004@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49E7E037.9080004-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Takuya Yoshikawa <yoshikawa.takuya-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Carl-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 17 Apr 2009 10:49:43 +0900
Takuya Yoshikawa <yoshikawa.takuya-gVGce1chcLdL9jVzuh4AOg@public.gmane.org> wrote:

> Hi,
> 
> I have a few question.
>    - I have not yet fully understood how your controller are using
>      bio_cgroup. If my view is wrong please tell me.
> 
> o In my view, bio_cgroup's implementation strongly depends on
>    page_cgoup's. Could you explain for what purpose does this
>    functionality itself should be implemented as cgroup subsystem?
>    Using page_cgoup and implementing tracking APIs is not enough?

I'll definitely do "Nack" to add full bio-cgroup members to page_cgroup.
Now, page_cgroup is 40bytes(in 64bit arch.) And all of them are allocated at
boot time as memmap. (and add member to struct page is much harder ;)

IIUC, feature for "tracking bio" is just necesary for pages for I/O.
So, I think it's much better to add misc. information to struct bio not to the page.
But, if people want to add "small hint" to struct page or struct page_cgroup
for tracking buffered I/O, I'll give you help as much as I can.
Maybe using "unused bits" in page_cgroup->flags is a choice with no overhead.

Thanks,
-Kame
