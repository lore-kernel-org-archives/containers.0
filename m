From: =?UTF-8?B?SmFuIMW7YXJza2k=?= <jan.zarski-AO0Vv05Z6LmrDJvtcaxF/A@public.gmane.org>
Subject: cointener not run property
Date: Fri, 13 Jul 2012 09:24:57 +0200
Message-ID: <4FFFCD49.7080602@symetria.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
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

Hello all,
i try run container cloudlinux6 on centos6. When i do:
#/lxc/bin/lxc-start -n cloud6-01 -d --logfile=/home/toor/lxc-start.log 
--logpriority=WARN
in log file i see:
       lxc-start 1342162846.243 WARN     lxc_cgroup - using deprecated 
ns_cgroup
       lxc-start 1342162846.290 WARN     lxc_conf - failed to mount 
'/dev/pts/2'->'/lxc/lib/lxc/rootfs/dev/tty1'
       lxc-start 1342162846.291 WARN     lxc_conf - failed to mount 
'/dev/pts/3'->'/lxc/lib/lxc/rootfs/dev/tty2'
       lxc-start 1342162846.312 WARN     lxc_console - console input 
disabled

when i want run:
#/lxc/bin/lxc-console -n cloud6-01
i see:
lxc-console: console denied by 'cloud6-01'

can You help me? it will be my first visualisation, and Im not 
linux-expert, so please - be tolerant.

--
DekeR
