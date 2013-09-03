From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [Announce] Checkpoint-restore tool v0.7
Date: Tue, 3 Sep 2013 16:05:06 +0400
Message-ID: <5225D072.6070300@parallels.com>
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
To: CRIU <criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi, all!

The checkpoint-restore tool v0.7 release is ready and out,
  the changelog is at  http://criu.org/Download/criu/0.7
  the sources are at   http://download.openvz.org/criu/criu-0.7.tar.bz2

The main news about the release is that the ptrace extension to get/set sigmask
on processes and the memory changes tracker (a.k.a. soft-dirty thing) are merged
into Linux-3.11. With this done, we finally have everything, that is really
critical for C/R, and thus the project is no longer *that* kernel-dependent.

That said, from now on we shall concentrate on improving the tool performance and
stability, rather than adorning the kernel :) Also, we no longer have to keep the
CRIU releases in sync with the kernel releases, so the next one we be done as
soon as it's ready, not when the Linux-3.12 is out.

Thanks everyone who helped with the v0.7, especially with the soft-dirty stuff!

Have fun!
