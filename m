From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: reduce size of per-cpu-stat to be appropriate
 size.
Date: Fri, 14 Nov 2008 17:06:37 +0900
Message-ID: <20081114170637.7cc50951.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081113164201.GV29067@bolzano.suse.de>
	<20081113191837.18ed2ade.akpm@linux-foundation.org>
	<491CF609.3050203@cn.fujitsu.com>
	<20081114132840.98d38f12.kamezawa.hiroyu@jp.fujitsu.com>
	<20081114144926.d91f36fd.kamezawa.hiroyu@jp.fujitsu.com>
	<491D2C21.5000600@linux.vnet.ibm.com>
	<20081114164812.a0d70ef5.kamezawa.hiroyu@jp.fujitsu.com>
	<491D2E6C.1000009@cn.fujitsu.com>
	<491D30E5.7080608@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753605AbYKNIHd@vger.kernel.org>
In-Reply-To: <491D30E5.7080608@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Blunck <jblunck@suse.de>, containers@lists.osdl.org, Linux-Kernel Mailinglist <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

On Fri, 14 Nov 2008 13:33:49 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Li Zefan wrote:
> >>>> +static int mem_cgroup_size(void)
> >>> inline this function?
> >>>
> >> necessary ? 
> >>
> > 
> > Not so necessary IMO. It's called when a cgroup is created and removed, that
> > is mkdir and rmdir, where performance is not critical.
> > 
> 
> I think most new compilers can automatically inline such functions, but a hint
> for the older ones is always a good practice.
> 

Adding "inline" is easy. But, IMHO, adding "inline" to not-performance-critical part
is just confusing people.
I want to see "inline" where inline is obviously good/necessary for performance.

Thanks,
-Kame
