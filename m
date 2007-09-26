From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH] allow "unlimited" limit value.
Date: Wed, 26 Sep 2007 10:23:43 +0900
Message-ID: <20070926102343.0f700503.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070925193900.1af6d871.kamezawa.hiroyu@jp.fujitsu.com>
	<46F8E7AE.2090309@linux.vnet.ibm.com>
	<20070925202954.4e477564.kamezawa.hiroyu@jp.fujitsu.com>
	<46F8F6FE.7040006@linux.vnet.ibm.com> <46F907CE.1060807@openvz.org>
	<46F90DCA.5030209@linux.vnet.ibm.com> <46F90E48.6080603@openvz.org>
	<20070926000510.7d956db8.kamezawa.hiroyu@jp.fujitsu.com>
	<46F925ED.20303@openvz.org>
	<20070926003056.7df087a0.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.0.9999.0709251205390.19001@chino.kir.corp.google.com>
	<46F95FD7.3010204@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46F95FD7.3010204-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 26 Sep 2007 00:51:59 +0530
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> David Rientjes wrote:

> Yes, I prefer 0 as well and had that in a series in the Lost World
> of my earlier memory/RSS controller patches. I feel now that 0 is
> a bit confusing, we don't use 0 to mean unlimited, unless we
> treat the memory.limit_in_bytes value as boolean. 0 is false,
> meaning there is no limit, > 0 is true, which means the limit
> is set and the value is specified to the value read out.

I prefer 0 than -1, too

Thanks,
-Kame
