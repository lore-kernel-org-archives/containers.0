From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 00/10] CGroup API files: Various cleanup to CGroup control
	files
Date: Tue, 26 Feb 2008 15:48:50 +0800
Message-ID: <47C3C462.4000706__5241.92125672034$1204012348$gmane$org@cn.fujitsu.com>
References: <20080223224725.115590000@menage.corp.google.com>	
	<47C3862D.8080603@cn.fujitsu.com>
	<6599ad830802252219p77f41917u7c6c137c8e5448e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830802252219p77f41917u7c6c137c8e5448e0-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Mon, Feb 25, 2008 at 7:23 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>>  Should those pathces be rebased againt 2.6.25-rc3 ?
>>
> 
> No, because they're against 2.6.25-rc2-mm1, which is already has (I
> think) any of the new bits in 2.6.25-rc3 that would be affected by
> these patches.
> 
> Paul

-rc2-mm1 came out on 2008-02-16, but the patches I posted several days ago
has been merged into -rc3, so your patches don't apply now. :(

Think about ./MAINTAINERS update and set up a git tree for development of
cgroup and cgroup subsystems as Andrew suggested. :)
