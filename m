From: Rob van der Hoeven <robvanderhoeven-nv30jWqA7Mk@public.gmane.org>
Subject: Program Space, a new lightweight virtualization technology
Date: Mon, 06 Jan 2014 13:17:33 +0100
Message-ID: <1389010653.4432.52.camel@pentium.freedom.box>
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

I'm proud to announce a new lightweight virtualization technology called
Program Space which I developed over the past months.

Program Space is very lightweight. It is created and managed by a small
program called psc (Program Space control) which starts a small psd
daemon of which the namespace configuration can be configured. Programs
running in Program Space are started as children of this daemon.

The psc program is designed to be used in scripts. It makes it possible
to use ordinary system utilities like ip, mount and iptables for the
configuration of the namespaces. 

How things work is explained in the following article:

http://freedomboxblog.nl/program_space

The sourcecode for the psc program can be viewed at:

http://freedomboxblog.nl/sourcecode_psc

or downloaded at:

http://freedomboxblog.nl/data/pscs-0.7.tar.gz

The download contains what I call the Program Space Construction Set
(PSCS). It not only includes the sourcecode for psc, but also some
scripts that show you how psc can be used to setup a rootfs, network or
create a full Program Space containing a LAMP stack running Wordpress.

Enjoy,
Rob van der Hoeven
http://freedomboxblog.nl
