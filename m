From: "Krishna Vamsi-B22174" <avamsi-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: Network Namespace-1000 networks with Overlap Addresses
Date: Mon, 13 Apr 2009 19:40:09 -0700
Message-ID: <B2EBF6E450E65C4F8CFEE8947E1905600298E2FF@az33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

 
 
Hi,
 
I am a newbie  to this list.  Here is my use case , we have  Loadable
Kernel Module which applies security to
the packets arriving from 1000 networks with overlap addresses. There
are 3 different  user space process which handles 
control traffic  from these 1000 networks .   
 
Please let me know
 
1)How to create a Network Namespace Object ?
2)How to delete a Network Namespace Object ?
3)Can these 3  user space process see all the Network Namespace objects
created in the kernel ?
 If so, how can they access these objects?
4)How to group 2-3 interfaces under a particular Network Namespace ?
 
Is there any patch available to achieve the above use case ?
 
 
Regards
    Vamsi
