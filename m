From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [Announce] Checkpoint-restore tool v0.3
Date: Tue, 11 Dec 2012 22:04:27 +0400
Message-ID: <50C775AB.70706__24118.1754893207$1355251459$gmane$org@parallels.com>
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
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, CRIU <criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: "users-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <users-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi!

The Linux-v3.7 is out, and it's good time to release the next version
of the checkpoint-restore tool.

This is mostly bugfix and improvements release, however it's worth
mentioning some new interesting features

  * Proper COW mappings handling
    Now anonymous private mappings are not COW-ed at restore, but
    pages that were shared remain such [1]

  * Full support for PF_PACKET sockets, thus letting us to C/R the
    tcpdump tool

  * The --shell-job option, which makes it possible to dump apps
    launched from one shell and restore them in another [2]

Some features are still available with the custom kernel, but things
are eventually getting merged upstream. In particular the 3.7 now has
support for C/R-ing of LXC containers' network devices, the initial
support for packet sockets and a couple of fixes for TCP repair code.


The v0.3 can be downloaded from
http://download.openvz.org/criu/crtools-0.3.tar.bz2
The project home is at http://criu.org

[1] https://plus.google.com/103175467322423551911/posts/bkgqbGTHfSt
[2] https://plus.google.com/103175467322423551911/posts/AYEu9w5HXiH

Thanks,
Pavel
