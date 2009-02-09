From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] liblxc: Update lxc-debian to use the lenny release
Date: Mon, 09 Feb 2009 15:43:11 -0800
Message-ID: <87d4dr41o0.fsf@caffeine.danplanet.com>
References: <1233825739.28338.22.camel@localhost>
	<1233826353.28338.35.camel@localhost> <49906491.8050200@free.fr>
	<1234213118.29561.17.camel@localhost> <4990A410.3040701@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4990A410.3040701-GANU6spQydw@public.gmane.org> (Daniel Lezcano's message of "Mon, 09
	Feb 2009 22:45:52 +0100")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

DL> It may be possible to use yum like debootstrap for an minbase
DL> fedora install.

Yep, something like the following should work:

  root=/path/to/tmproot
  mkdir -p $root/var/lib/rpm
  rpm --root $root --initdb
  rpm --root $root -Uvfh --nodeps http://fedora.osuosl.org/linux/releases/10/Fedora/i386/os/Packages/fedora-release-10-1.noarch.rpm
  yum --installroot=$root -y groupinstall Base

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
