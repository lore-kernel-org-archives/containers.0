From: Philip Rhoades <phil-8eKeQ+h1VH4pAS55Wn97og@public.gmane.org>
Subject: Getting started - Error message
Date: Fri, 04 Mar 2011 05:55:30 +1100
Message-ID: <4D6FE422.1040807@pricom.com.au>
Reply-To: phil-8eKeQ+h1VH4pAS55Wn97og@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

People,

I used this info to get started on Fedora 14 x86_64:

http://www.techrepublic.com/blog/opensource/introducing-linux-virtual-containers-with-lxc/1289

and everything seems happy when doing the setup stuff but when I try to run:

/usr/bin/lxc-execute -n test -f /etc/lxc/lxc-test.conf /bin/bash

I get:

lxc-execute: network is not created for 'lxc.network.link' = 'br0 
lxc.network.hwaddr = 4a:49:43:49:79:bd' option

lxc-execute: failed to process 'lxc.network.link = br0 
lxc.network.hwaddr = 4a:49:43:49:79:bd
'
lxc-execute: failed to read configuration file

but the conf file is readable:

-rw-r--r-- 1 root root 215 Mar  4 05:29 /etc/lxc/lxc-test.conf

Suggestions?

Thanks,

Phil.
-- 
Philip Rhoades

GPO Box 3411
Sydney NSW	2001
Australia
E-mail:  phil-8eKeQ+h1VH4pAS55Wn97og@public.gmane.org
