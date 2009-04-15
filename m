From: "Krishna Vamsi-B22174" <avamsi-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: [PATCH 0/6] netns: add linux-vrf features via network namespaces
Date: Tue, 14 Apr 2009 20:14:24 -0700
Message-ID: <B2EBF6E450E65C4F8CFEE8947E1905600298E536@az33exm24.fsl.freescale.net>
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

 
 
Hi Vivien Chappelier,
 
 
In my use case, a security appliance provides security to 100 networks
and 
a user space process which receives control traffic from these 100
networks.
Earlier we were using VRF ID patch , so my objective of having separate
routing table 
for each network was achieved. 
 
Now I have to customize  2.6.27 kernel to achieve the above requirement.

 
I have compiled the 2.6.27 kernel with 
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
# CONFIG_IPC_NS is not set
# CONFIG_USER_NS is not set
# CONFIG_PID_NS is not set
CONFIG_NET_NS=y
CONFIG_SYSFS=y
CONFIG_MACVLAN=y
CONFIG_VETH=y
 
 
Please clarify me
 
1)Will these 6 patches satisfy my requirement ?
  Do I need any additional patches other than the 6 patches?
  
2)Please let me know the recommended iproute2 version  .
 
3)Network Namespace object ID starts from 1 ... 4095. Is my
understanding correct ?
 
4)Are there any test programs to verify ?If so what is the recommended
glibc version to compile these
  test programs?
 
  I will post my comments after testing this patch.
 
Regards
    Vamsi
