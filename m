From: Kirill Korotaev <dev-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [Devel] Re: [RFC] Container mini-summit agenda for Sept 3, 2007
Date: Fri, 31 Aug 2007 19:59:15 +0400
Message-ID: <46D83AD3.4090404@sw.ru>
References: <46D69653.1090003@fr.ibm.com>
	<46D78A5E.3030304@cs.columbia.edu>	<46D824FA.2080300@fr.ibm.com>
	<46D82CC4.5010809@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46D82CC4.5010809-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Rohit Seth <rohitseth-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, office-xGb7/i2pWyrYtjvyW6yDsg@public.gmane.org, Alasdair Kergon <agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Cedric Le Goater wrote:
>>>Many of these were discussed in a recent Zap paper present in USENIX:
>>>http://www.ncl.cs.columbia.edu/publications/usenix2007_fordist.pdf
>>>The paper describes important design choices in Zap (but I'm biased ...).
>>>I think it may serve as an appetizer for the discussion :P
>>
>>Thanks, I hope we all have time to read it.
> 
> 
> The abstract says : 
> 
> "...
> Our results show checkpoint and restart times 3 to 55 times faster than 
> OpenVZ and 5 to 1100 times faster than Xen."
> 
> I'm impressed ! :) When can we play it ?
> 
> Thanks for the appetizer !

It is totally unfair to compare full virtualization solution such as OpenVZ
with sync on VE stop (for quotas consistency) and which doesn't require shared storage for migration
with POC which uses shared storage in the paper.

I'm not sure why author didn't pay attention to these HUGE differences in configuration...
Maybe because 1100x times is so incredible :@)

Thanks,
Kirill
