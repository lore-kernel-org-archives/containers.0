From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: Network Namespace ARP support
Date: Thu, 04 Sep 2008 16:50:10 +0200
Message-ID: <48BFF5A2.2050206@fr.ibm.com>
References: <C4E59F1D.15C93%echaudron@extremenetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <C4E59F1D.15C93%echaudron-SvgryPHmmKB+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Eelco Chaudron <echaudron-SvgryPHmmKB+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Cc: "Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Eelco Chaudron wrote:
> Hi All,
> 
> I was looking at the network namespaces implementation for ARP, and I
> was wondering why the struct net abstraction was done in the core
> neighbour functions, and not at the struct neigh_table arp_tbl level
> (i.e. one arp_tbl per namespace)?
> 
> One problem I could find with the current implementation is that the
> "struct neigh_statistics *stats" are global for all namespaces,
> whereas you might want to see these statistics per namespace.
> 
> It would be nice if I could get some insight in some of the design
> decisions, as I'm new to this area...
> 
> Thanks,
> 

Hi Eelco,

In order to not waste memory duplicating redundant information with the 
tables, the neighbour per namespace has be made in the core neighbour 
functions which is the common code between the different protocols ipv4 
and ipv6.

As you mention, the statistics are in the table and because there is a 
single table there is a no statistics per namespace. Making this 
resource per namespace will consist in moving the stats structure to the 
network namespace structure, I guess, and not creating multiple neigh 
tables.

This decision has been made for the socket hash tables and for the 
routing cache table too, AFAIR this is for avoiding memory fragmentation 
and cache misses.

   -- Daniel
