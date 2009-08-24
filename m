From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Devel] Re: [lxc-devel] Memory Resources
Date: Mon, 24 Aug 2009 12:47:57 +0530
Message-ID: <20090824071757.GQ29572@balbir.in.ibm.com>
References: <ac1c4bf20908231117sb180e78q3eed64db3573ec35@mail.gmail.com>
	<ac1c4bf20908231138j2ce7bb48v69a8ac8ede6bc314@mail.gmail.com>
	<ac1c4bf20908231222t182e6ca6u716b98e13d85cbad@mail.gmail.com>
	<4A91A103.6020207@free.fr>
	<ac1c4bf20908231318v1586c2ciffd3df5fe1b70c20@mail.gmail.com>
	<4A91ADE1.9090204@free.fr>
	<ac1c4bf20908231412m634fdf9h686f6bd24eb95a14@mail.gmail.com>
	<20090824092739.70d56a5b.kamezawa.hiroyu@jp.fujitsu.com>
	<90D306BE6EBC8D428A824FBBA7A3113DE076E221@ronja.maurer-it.com>
	<20090824155835.94f6b88f.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090824155835.94f6b88f.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org" <kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>, Dietmar Maurer <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org>, Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>, "lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org" <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

* KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2009-08-24 15:58:35]:

> On Mon, 24 Aug 2009 08:17:06 +0200
> Dietmar Maurer <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org> wrote:
> 
> > > > how about memsw_limit for swap? :>
> > > > I am looking for swap usage statistics from cgroup right now from
> > > > memcontrol.c :) but as you did the idea is good and should be add to
> > > the
> > > > kernel and lxc-tools :)
> > > >
> > > 
> > > Hmm, why meminfo is necessary ? For cheating top/free/... etc ?
> > 
> > Many servers use that info to control the use of resources. For example, they do not span any more server processes if memory is low.
> > 
> > If you do not have that info correct, all those programs fails (they try to allocate much more resources than available).
> > 
> 
> Hm, duplicating information for keeping binary compatibility for apps ?
> What other stat does ? 
> For example, 
> 	- load average
> 	- cpu usage %user, %sys, %iowait, etc..
> 	- fork-per-sec
> 
> One difficulty I think of is that memcg's limit-usage doesn't means "free".
> But, hmm, showing "meminfo" in popular/user-friendly format is not very bad.
> Balbir, how do you think ?
>

Sorry, I've missed the context and unable to follow the discussion.
IIUC, the request is to show per-container statistics?
 
> If you write a patch, plz onto the newest mmotm.
> *And*, now, Nishimura-san is posting "show # of swap usage directly" patch.
> It will be a help for you.

-- 
	Balbir
