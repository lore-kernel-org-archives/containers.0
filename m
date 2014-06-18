From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [Announce] Checkpoint-restore tool v1.3-rc2
Date: Wed, 18 Jun 2014 13:55:56 +0400
Message-ID: <53A1622C.4000207@parallels.com>
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

Hi,

So, the 2nd candidate for 1.3 is out!

New features include C/R of tasks-to-cgroups layout and native support
for external bind mounts. The latter thing turned out to be absolutely
necessary for LXC and Docker support, as mountpoints with external root
is very typical to these containers. We also have many bugfixes, mainly
in memory restore and mounpoints c/r.


I'd like to thank Google guys Filipe and Saied who joined us during this
cycle for problem reports, patches, fruitful discussions and a quick but
useful HOWTO about CRIU + Docker.

And also welcome Tycho and Serge from Canonical, hopefully we'll soon have
full LXC and CRIU integration and tag the 1.3  :)


Full changelog is http://criu.org/Download/criu/1.3-rc2
Tarball with sources is http://download.openvz.org/criu/criu-1.3-rc2.tar.bz2
News and docs are still at http://criu.org and https://plus.google.com/+CriuOrg


Stay tuned and have fun!

Thanks,
Pavel
