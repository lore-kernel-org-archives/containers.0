From: Dilip Daya <dilip.daya-VXdhtT5mjnY@public.gmane.org>
Subject: Help! - kernel: ip_local_deliver_finish: proto 108 (IPComp) isn't
	netns-ready
Date: Mon, 07 Nov 2011 14:43:07 -0500
Message-ID: <1320694987.2564.14.camel@pro6455b.example.com>
Reply-To: dilip.daya-VXdhtT5mjnY@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Please let me know if this is the correct list for a network-namespace
question:

Environment:
- v3.0.8 kernel (x86_64)
- One system with 2 network-namespaces (netns0 and netns1) configured
  with multiple physical NICs assigned.
- LTP-network tests performed between these two network namespaces,
  by entering netns1 (# ip netns exec netns1 bash), then executing 
  LTP-network tests between netns0 and netns1.

The following LTP tests produced: "kernel: ip_local_deliver_finish:
proto 108 isn't netns-ready"

/usr/lib/ltp/testcases/bin/icmp4-multi-diffip06
/usr/lib/ltp/testcases/bin/tcp4-multi-diffip13
/usr/lib/ltp/testcases/bin/udp4-multi-diffip06
/usr/lib/ltp/testcases/bin/udp4-multi-diffnic06
/usr/lib/ltp/testcases/bin/udp4-multi-diffport06

i.e. network stack with "ip_local_deliver_finish: proto 108 isn't
netns-ready":

ICMP / UDP / TCP
IPv4
IPComp (mode: transport)
IPSec

=> Does this mean that IPComp (mode: transport) is not network namespace
   ready?  Is this a bug or IPComp is not netns enabled?  since IPv6
    works fine.

Thanking you all in advance.

-DilipD.
