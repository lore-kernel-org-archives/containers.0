From: Eelco Chaudron <echaudron-SvgryPHmmKB+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Network Namespace ARP support
Date: Thu, 4 Sep 2008 14:20:13 +0200
Message-ID: <C4E59F1D.15C93%echaudron@extremenetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Language: en
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi All,

I was looking at the network namespaces implementation for ARP, and I was wondering why the struct net abstraction was done in the core neighbour functions, and not at the struct neigh_table arp_tbl level (i.e. one arp_tbl per namespace)?

One problem I could find with the current implementation is that the "struct neigh_statistics *stats" are global for all namespaces, whereas you might want to see these statistics per namespace.

It would be nice if I could get some insight in some of the design decisions, as I'm new to this area...

Thanks,


Eelco


________________________________
DISCLAIMER:
This e-mail and any attachments to it may contain confidential and proprietary material and is solely for the use of the intended recipient. Any review, use, disclosure, distribution or copying of this transmittal is prohibited except by or on behalf of the intended recipient. If you have received this transmittal in error, please notify the sender and destroy this e-mail and any attachments and all copies, whether electronic or printed.
