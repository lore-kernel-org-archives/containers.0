From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH] memory cgroup enhancements updated [8/10] add
 pre_destroy handler
Date: Thu, 25 Oct 2007 00:46:14 +0900
Message-ID: <20071025004614.30006987.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071019182436.485e20cd.kamezawa.hiroyu@jp.fujitsu.com>
	<20071019183544.0f5172b2.kamezawa.hiroyu@jp.fujitsu.com>
	<471F5B7E.2020007@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <471F5B7E.2020007-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 24 Oct 2007 20:19:34 +0530
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> > +	/*
> > +	 * Notify subsyses that rmdir() request comes.
> > +	 */
> > +	for_each_subsys(root, ss) {
> > +		if ((cont->subsys[ss->subsys_id]) && ss->pre_destroy)
> > +			ss->pre_destroy(ss, cont);
> > +	}
> > 
> 
> Is pre_destroy really required? Can't we do what we do here in destroy?
>

I think keeping "we can destroy cgroup only when refcnt=0" semantics is better.

Thanks,
-Kame
