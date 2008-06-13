From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Date: Fri, 13 Jun 2008 09:34:36 +0900
Message-ID: <20080613093436.ca1a6ded.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080612131748.GB8453@us.ibm.com>
	<20080606105235.3c94daaf.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806110017t5ebeda78id1914d179a018422@mail.gmail.com>
	<20080611164544.94047336.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806110104n99cdc7h80063e91d16bf0a5@mail.gmail.com>
	<20080611172714.018aa68c.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806110148v65df67f8ge0ccdd56c21c89e0@mail.gmail.com>
	<20080612140806.dc161c77.kamezawa.hiroyu@jp.fujitsu.com>
	<27043861.1213277688814.kamezawa.hiroyu@jp.fujitsu.com>
	<20080612210812.GA22948@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080612210812.GA22948-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 12 Jun 2008 16:08:12 -0500
"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:

> > Assume a thread group contains threadA, threadB, threadC.
> > 
> > I wanted to ask "Can threadA, and threadB, and threadC
> > be in different cgroups ? And if so, how ns cgroup handles it ?"
> > 
> > Maybe I don't understand ns cgroup.
> 
> In part yes, but nonetheless a very interesting question when it comes
> to composition of cgroups!
> 
> Yes, you can have threads in different cgroups.  The ns cgroup just
> tracks nsproxy unshares.  So if you run the attached program and look
> around, you'll see the first thread is in /cg/taskpid while the second
> one is in /cg/taskpid/secondthreadpid.
> 
> Clearly, composing this with a cgroup which needs to keep threads in the
> same cgroup becomes problematic!
> 
> Interesting :)
> 

Thank you for kindly explanation. I'll take this into account. I confirmed
memory resouce controller should not get tasks's cgroup directly from "task"
and should get it from "mm->owner".

Thank you.

Regards,
-Kame
