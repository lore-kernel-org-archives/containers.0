From: Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] Container mini-summit agenda for Sept 3, 2007
Date: Mon, 3 Sep 2007 15:46:20 +0530
Message-ID: <20070903101619.GD6837@linux.vnet.ibm.com>
References: <46D69653.1090003@fr.ibm.com> <46DBC9C5.5060101@fr.ibm.com>
	<6599ad830709030203s50ad1ab1vb0cdf21be0ab023@mail.gmail.com>
	<46DBD4BE.4000901@openvz.org>
	<6599ad830709030248g4854a056y2f92b8a0fc12c48d@mail.gmail.com>
Reply-To: vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830709030248g4854a056y2f92b8a0fc12c48d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Kir Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Rohit Seth <rohitseth-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, office-xGb7/i2pWyrYtjvyW6yDsg@public.gmane.org, Alasdair Kergon <agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Sep 03, 2007 at 02:48:23AM -0700, Paul Menage wrote:
> OK. Am I right in thinking that CFS is expected to provide most of the
> CPU scheduler support that we need, when enhanced with Vatsa's group
> scheduling patches?

CFS pretty much provides the core logic to fairly divide the cpu as per
the weight of each group. One complication is with respect to SMP
load balance, to ensure that each group gets its fair share on all the
cpus put together. 

We have been experimenting with few ideas on the smp group fairness and expect
to send out the patches to Andrew in a week or two.

-- 
Regards,
vatsa
