From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [Announce] Checkpoint-restore tool v1.3-rc1
Date: Fri, 25 Apr 2014 15:57:32 +0400
Message-ID: <535A4DAC.9030602@parallels.com>
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
To: CRIU <criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello everyone!

I'm glad to announce the first release candidate for CRIU version 1.3.

We've been working on making support for C/R of LXC containers and though
not everything is ready yet, we have something to show.

So, first of all, we have support for multiple mount namespaces, which are
now always created by systemd. Another thing is that we have an ability to
re-attach restored LXC container back to watching daemon after restore (the
LXC part should appear soon). And we have started implementing the LXC
live-migration in p.haul, so once the re-attach is finished p.haul will be
able to do it "for real" :)

Another prominent feature is support for AArch64.


For full changelog see the http://criu.org/Download/criu/1.3-rc1
The sources can be get from http://download.openvz.org/criu/criu-1.3-rc1.tar.bz2

Docs and news are as usual at http://criu.org/Main_Page
And the P.Haul stuff sits at https://github.com/xemul/p.haul

Thanks,
Pavel
