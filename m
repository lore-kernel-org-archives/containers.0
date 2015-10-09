From: Zhang Haoyu <yuzhou-e3F2ONz+ghBBDgjK7y7TUQ@public.gmane.org>
Subject: pidns: Make pid accounting and pid_max per namespace
Date: Fri, 9 Oct 2015 18:29:20 +0800
Message-ID: <56179700.3010703@mogujie.com>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

I started multiple docker containers in centos6.6(linux-2.6.32-504.16.2),
and there's one bad program was running in one container.
This program produced many child threads continuously without free, so more and
more pid numbers were consumed by this program, until hitting the pix_max limit (32768
default in my system ).

What's worse is that containers and host share the pid numbers resource, so new program
cannot be produced any more in host and other containers.

And, I clone the upstream kernel source from
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
This problem is still there, I'm not sure.

IMO, we should isolate the pid accounting and pid_max between pid namespaces,
and make them per pidns.
Below post had request for making pid_max per pidns.
http://thread.gmane.org/gmane.linux.kernel/1108167/focus=1111210

Thanks,
Zhang Haoyu
